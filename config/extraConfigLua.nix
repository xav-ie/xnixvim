_: {
  config = {
    extraConfigLua =
      let
        clipBoardConfig = # lua
          ''
            -- I always want yanks synchronized with system and "selection"
            -- (IDK what that is) clipboard
            -- https://github.com/ch3n9w/dev/blob/319deb662ff50b58f5b643fbd9327ecb00919886/nvim/lua/autocmd.lua#L26-L34
            vim.api.nvim_create_autocmd('TextYankPost', {
                callback = function()
                    vim.highlight.on_yank()
                    local clipboard = require('vim.ui.clipboard.osc52')
                    local copy_to_unnamedplus = clipboard.copy('+')
                    copy_to_unnamedplus(vim.v.event.regcontents)
                    local copy_to_unnamed     = clipboard.copy('*')
                    copy_to_unnamed(vim.v.event.regcontents)
                end
            })
            -- I also want paste synchronized, too, but Zellij is preventing this >:(
            -- https://github.com/zellij-org/zellij/issues/2647
            -- https://github.com/zellij-org/zellij/issues/3135

            -- Fix copy/paste for Neovide
            -- https://neovide.dev/faq.html?highlight=clipboard#how-can-i-use-cmd-ccmd-v-to-copy-and-paste
            if vim.g.neovide then
              vim.keymap.set('n', '<D-s>', ':w<CR>')      -- save
              vim.keymap.set('v', '<D-c>', '"+y')         -- copy
              vim.keymap.set('n', '<D-v>', '"+P')         -- paste
              vim.keymap.set('v', '<D-v>', '"+P')         -- paste
              vim.keymap.set('c', '<D-v>', '<C-R>+')      -- paste
              vim.keymap.set('i', '<D-v>', '<ESC>l"+Pli') -- paste
              -- set clipboard to unnamedplus
              vim.opt.clipboard = "unnamedplus"
            else
              local function paste()
               -- this is inaccurate and not correct, but it is okay enough
               return {
                  vim.fn.split(vim.fn.getreg(""), '\n'),
                  vim.fn.getregtype("")
                }
              end

              vim.g.clipboard = {
                name = 'OSC 52',
                copy = {
                  ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
                  ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
                },
                paste = {
                  ['+'] = paste,
                  ['*'] = paste,
                  -- TODO: get OSC paste working for Zellij first
                  -- ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
                  -- ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
                },
              }
            end

            vim.api.nvim_set_keymap("",  '<D-v>', '+p<CR>',
              {noremap = true, silent=true})
            vim.api.nvim_set_keymap('!', '<D-v>', '<C-R>+',
              {noremap = true, silent=true})
            vim.api.nvim_set_keymap('t', '<D-v>', '<C-R>+',
              {noremap = true, silent=true})
            vim.api.nvim_set_keymap('v', '<D-v>', '<C-R>+',
              {noremap = true, silent=true})
          '';

        # better nu support in nvim
        # https://www.kiils.dk/en/blog/2024-06-22-using-nushell-in-neovim/
        nuSupport = # lua
          ''
            local posix_shell_options = {
              shellcmdflag = "-c",
              shellpipe = "2>&1 | tee",
              shellquote = "",
              shellredir = ">%s 2>&1",
              shelltemp = true,
              shellxescape = "",
              shellxquote = "",
            }

            local nu_shell_options = {
              shellcmdflag = "--login --stdin --no-newline -c",
              shellpipe = "| complete \z
                           | update stderr { ansi strip } \z
                           | tee { get stderr | save --force --raw %s } \z
                           | into record",
              shellquote = "",
              shellredir = "out+err> %s",
              shelltemp = false,
              shellxescape = "",
              shellxquote = "",
            }

            local function set_options(options)
              for k, v in pairs(options) do
                vim.opt[k] = v
              end
            end


            local function apply_shell_options()
              if vim.opt.shell:get():match("nu$") ~= nil then
                set_options(nu_shell_options)
              else
                set_options(posix_shell_options)
              end
            end

            apply_shell_options()

            vim.api.nvim_create_autocmd("OptionSet", {
              pattern = "shell",
              callback = function()
                apply_shell_options()
              end,
            })
          '';

        copyHelpers = # lua
          ''
            local function CopyToClipboard(text)
              -- Copy to the system clipboard register
              vim.fn.setreg('+', text)
              vim.notify('Copied to clipboard: ' .. text,
                vim.log.levels.INFO, { title = "Clipboard" })
            end

            function GetAbsolutePath()
              return vim.fn.expand('%:p')
            end
            function GetPath()
              return vim.fn.expand('%:t')
            end
            function GetRelativePath()
              return vim.fn.fnamemodify(vim.fn.expand('%'), ':~:.')
            end


            vim.keymap.set('n', '<leader>ca', function()
              CopyToClipboard(GetAbsolutePath())
            end, { desc = "Copy [a]bsolute path" })

            vim.keymap.set('n', '<leader>cp', function()
              CopyToClipboard(GetPath())
            end, { desc = "Copy [p]ath" })

            vim.keymap.set('n', '<leader>cr', function()
              CopyToClipboard(GetRelativePath())
            end, { desc = "Copy [r]elative path" })
          '';

        quickfixToggle = # lua
          ''
            function ToggleQuickfix()
              local qf_exists = false
              for _, win in pairs(vim.fn.getwininfo()) do
                if win["quickfix"] == 1 then
                  qf_exists = true
                  break
                end
              end
              if qf_exists then
                vim.cmd("cclose")
              else
                vim.cmd("copen")
              end
            end

            vim.keymap.set('n', '<leader>tq',
              ToggleQuickfix, { desc = "Toggle [q]uickfix" })
          '';

        # Stolen from nekowinston
        recordingMacroNotification = # lua
          ''
            vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
              callback = function(data)
                local msg = data.event == "RecordingEnter"
                            and "Recording macro..." or "Macro recorded"
                vim.notify(msg, vim.log.levels.INFO, { title = "Macro" })
              end,
              desc = "Notify when recording macro",
            })
          '';

        # automatically jump to unstaged section when fugitive-summary buffer
        # is loaded
        fugitiveJumper = # lua
          ''
            vim.api.nvim_create_autocmd("User", {
              pattern = "FugitiveIndex",
              callback = function()
                vim.cmd("normal gu")
              end,
            })
          '';

        diagnosticFloatHighlighting = # lua
          ''
            -- Highlight quoted text in diagnostic floats
            local original_open_float = vim.diagnostic.open_float
            vim.diagnostic.open_float = function(opts, ...)
              local bufnr = original_open_float(opts, ...)
              if bufnr then
                vim.defer_fn(function()
                  local ns = vim.api.nvim_create_namespace('diagnostic_quoted')
                  for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
                    for s, e in string.gmatch(line, "()'[^']*'()") do
                      vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, s - 1, {
                        end_col = e - 1,
                        hl_group = 'DiagnosticQuoted',
                        hl_mode = 'replace',
                        priority = 10000
                      })
                    end
                  end
                end, 0)
              end
              return bufnr
            end
          '';

        # Override EditorConfig's tab settings to use 2-space visual indents
        forceTabstop = # lua
          ''
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
              callback = function()
                vim.opt_local.tabstop = 2
                vim.opt_local.shiftwidth = 2
                vim.opt_local.softtabstop = 2
              end,
              desc = "Force 2-space tab display and indentation",
            })
          '';

      in
      # lua
      ''
        ${clipBoardConfig}
        ${nuSupport}
        ${copyHelpers}
        ${quickfixToggle}
        ${recordingMacroNotification}
        ${fugitiveJumper}
        ${diagnosticFloatHighlighting}
        ${forceTabstop}
      '';
  };
}
