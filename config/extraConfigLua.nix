{ ... }:
{
  extraConfigLua =
    let
      clipBoardConfig = # lua
        ''
          local function paste()
           -- this is inaccurate and not correct, but it is okay enough
           return {vim.fn.split(vim.fn.getreg(""), '\n'), vim.fn.getregtype("")}
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

          -- I always want yanks synchronized with system and "selection" (IDK what that is) clipboard
          -- https://github.com/ch3n9w/dev/blob/319deb662ff50b58f5b643fbd9327ecb00919886/nvim/lua/autocmd.lua#L26-L34
          vim.api.nvim_create_autocmd('TextYankPost', {
              callback = function()
                  vim.highlight.on_yank()
                  local copy_to_unnamedplus = require('vim.ui.clipboard.osc52').copy('+')
                  copy_to_unnamedplus(vim.v.event.regcontents)
                  local copy_to_unnamed = require('vim.ui.clipboard.osc52').copy('*')
                  copy_to_unnamed(vim.v.event.regcontents)
              end
          })
          -- I also want paste synchronized, too, but Zellij is preventing this >:(
        '';

      # TODO: make better maps
      caseChangeFunctions = # lua
        ''
          -- Pascal Case, also highlights the cased words for easy lower-casing! :)
          vim.api.nvim_set_keymap('v', 'gp', [[:<C-u>'<,'>s/\%V\v\w+/\u\L&/g<CR>]], { noremap = true, silent = true })
          -- Title Case
          vim.api.nvim_set_keymap('v', 'gt', [[:<C-u>'<,'>s/\%V\v\w+/\u\L&/g<CR>:<C-u>silent! '<,'>s/\%V\<\(A\|An\|The\|And\|But\|Or\|Nor\|So\|Yet\|At\|By\|In\|Of\|On\|To\|Up\|For\|About\|Above\|Across\|After\|Against\|Along\|Among\|Around\|Before\|Behind\|Below\|Beneath\|Beside\|Between\|Beyond\|Down\|During\|Except\|From\|Inside\|Into\|Like\|Near\|Off\|Onto\|Out\|Outside\|Over\|Past\|Since\|Through\|Throughout\|Under\|Underneath\|Until\|With\|Within\|Without\|Is\|Be\|Am\|Are\|Was\|Were\|Has\|Have\|Had\)\>/\L&/g<CR>]], { noremap = true, silent = true })
          -- Sentence case
          vim.api.nvim_set_keymap('v', 'gs', [[:<C-u>try | '<,'>s/\%V\(\(^\|[.!?]\s*\)\)\zs\w/\u&/g | catch | endtry<CR>:<C-u>'<,'>normal! _vgU<CR>]], { noremap = true, silent = true })
          -- Stolen from nekowinston
          vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
            callback = function(data)
              local msg = data.event == "RecordingEnter" and "Recording macro..." or "Macro recorded"
              vim.notify(msg, vim.log.levels.INFO, { title = "Macro" })
            end,
            desc = "Notify when recording macro",
          })
        '';
      randomHighlightConfig = # lua
        ''
          -- TODO: how to use color scheme
          vim.cmd('highlight TSProperty guifg=#FFD242')
          vim.cmd('highlight TSType guifg=#00a0f0')
          vim.cmd('highlight TSNumber guifg=#be620a')
        '';
    in
    # lua
    ''
      ${randomHighlightConfig}
      ${clipBoardConfig}
      ${caseChangeFunctions}
    '';
}
