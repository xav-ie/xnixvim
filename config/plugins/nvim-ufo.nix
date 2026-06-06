{
  config,
  lib,
  ...
}:
{
  # Modern folding UI: treesitter/indent fold providers, peekable folds, and a
  # line-count fold text. foldlevel(start)=99 means files open fully unfolded —
  # this is the answer to the "don't open files pre-folded" TODO that kept
  # treesitter's own `folding` disabled (see treesitter.nix).
  # https://github.com/kevinhwang91/nvim-ufo
  # https://nix-community.github.io/nixvim/plugins/nvim-ufo
  config = {
    # Fold options must be in place before ufo attaches. 99 keeps everything
    # open on load; folds are then created on demand (za/zc, zM, zR).
    opts = {
      # No fold gutter: a width-1 foldcolumn renders nested folds as digits
      # (2, 3, …) which collide visually with git-heat's gutter bars. Folding
      # still works fully via za/zM/zR/zr/zK.
      foldcolumn = "0";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;
    };

    plugins.nvim-ufo = {
      enable = true;
      lazyLoad.enable = config.lazyLoad.enable;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
      settings = {
        # Fold kinds that stay collapsed when `zr` (openFoldsExceptKinds) runs,
        # so it reveals code while keeping boilerplate (comments, import blocks)
        # tucked away.
        close_fold_kinds_for_ft.default = [
          "imports"
          "comment"
        ];
        # Prefer treesitter folds, fall back to indent. No LSP provider, so
        # folding never waits on a language server.
        provider_selector = # lua
          ''
            function(_, _, _)
              return { 'treesitter', 'indent' }
            end
          '';
        # Append a "  N lines" count to the folded line, truncating the
        # preview text to fit. Adapted from the ufo wiki.
        fold_virt_text_handler = # lua
          ''
            function(virtText, lnum, endLnum, width, truncate)
              local newVirtText = {}
              local suffix = ('  %d '):format(endLnum - lnum)
              local sufWidth = vim.fn.strdisplaywidth(suffix)
              local targetWidth = width - sufWidth
              local curWidth = 0
              for _, chunk in ipairs(virtText) do
                local chunkText = chunk[1]
                local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                if targetWidth > curWidth + chunkWidth then
                  table.insert(newVirtText, chunk)
                else
                  chunkText = truncate(chunkText, targetWidth - curWidth)
                  local hlGroup = chunk[2]
                  table.insert(newVirtText, { chunkText, hlGroup })
                  chunkWidth = vim.fn.strdisplaywidth(chunkText)
                  if curWidth + chunkWidth < targetWidth then
                    suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                  end
                  break
                end
                curWidth = curWidth + chunkWidth
              end
              table.insert(newVirtText, { suffix, 'MoreMsg' })
              return newVirtText
            end
          '';
      };
    };

    keymaps = lib.nixvim.keymaps.mkKeymaps { options.silent = true; } [
      {
        mode = "n";
        key = "zR";
        action.__raw = "function() require('ufo').openAllFolds() end";
        options.desc = "Open all folds";
      }
      {
        mode = "n";
        key = "zM";
        action.__raw = "function() require('ufo').closeAllFolds() end";
        options.desc = "Close all folds";
      }
      {
        mode = "n";
        key = "zr";
        action.__raw = "function() require('ufo').openFoldsExceptKinds() end";
        options.desc = "Open folds except comments/imports";
      }
      {
        mode = "n";
        key = "zm";
        action.__raw = "function() require('ufo').closeFoldsWith() end";
        options.desc = "Close one more fold level";
      }
      {
        mode = "n";
        key = "zK";
        action.__raw = # lua
          ''
            function()
              -- Peek the folded lines in a popup; fall back to LSP hover when
              -- the cursor isn't on a closed fold.
              local winid = require('ufo').peekFoldedLinesUnderCursor()
              if not winid then
                vim.lsp.buf.hover()
              end
            end
          '';
        options.desc = "Peek fold / hover";
      }
    ];
  };
}
