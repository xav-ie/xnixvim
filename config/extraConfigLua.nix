{ ... }:
{
  extraConfigLua = # lua
    ''
      vim.opt.cmdheight = 0;
      -- corrects command auto-complete to first show the completion list, then further tabs 
      -- will cause complete auto-complete 
      vim.opt.wildmode = "list,full";
      vim.opt.spelllang = "en_us";
      -- vim.opt.spell = true;
      -- Not currently working. See other configurations on GitHub.
      vim.opt.spellfile = "~/.config/nvim/spell/en_us.utf-8.add";

      -- add border to diagnostic windows
      local _border = "single"
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = _border,
      })
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = _border,
      })
      vim.diagnostic.config {
        float = { border = _border },
      }

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

      -- TODO: how to use color scheme
      vim.cmd('highlight TSProperty guifg=#FFD242')
      vim.cmd('highlight TSType guifg=#00a0f0')
      vim.cmd('highlight TSNumber guifg=#be620a')


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

      if vim.g.neovide then
        vim.g.neovide_scale_factor = 1.1
        vim.g.neovide_cursor_vfx_mode = "pixiedust"
        -- TODO: add MacOS specific config
        vim.g.neovide_transparency = 0.8
        vim.g.neovide_touch_deadzone = 0.0
        -- only applies when launched with --no-vsync. Improves animation quite a bit.
        vim.g.neovide_refresh_rate = 144

        -- These two seem to have no effect (maybe on MacOS?):
        -- vim.g.neovide_text_gamma = 3.4
        -- vim.g.neovide_text_contrast = 2.0
      end
    '';
}
