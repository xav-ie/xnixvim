{
  helpers,
  lib,
  pkgs,
  ...
}:
{
  # Emoji, kaomoji, latex, math, nerd, etc.
  # https://github.com/nvim-telescope/telescope-symbols.nvim
  config = {
    extraPlugins = with pkgs.vimPlugins; [ telescope-symbols-nvim ];

    keymaps =
      # TODO: somehow export from ../../keymaps.nix and avoid duplication
      let
        modeKeys =
          mode:
          lib.attrsets.mapAttrsToList (
            key: action:
            { inherit key mode; } // (if builtins.isString action then { inherit action; } else action)
          );
        nm = modeKeys [ "n" ];
        telescopeSymbolsBinding =
          keyset: # lua
          ''
            <cmd>lua require("telescope.builtin").symbols { sources = { '${keyset}' } }<CR>
          '';
      in
      helpers.keymaps.mkKeymaps { options.silent = true; } (nm {
        # TODO: somehow prefix the keymap description properly
        # and get rid of repetition
        "<leader>fye" = {
          action = telescopeSymbolsBinding "emoji";
          options = {
            desc = "[e]moji";
          };
        };
        "<leader>fyg" = {
          action = telescopeSymbolsBinding "emoji";
          options = {
            desc = "[g]itmoji";
          };
        };
        "<leader>fyj" = {
          action = telescopeSymbolsBinding "julia";
          options = {
            desc = "[j]ulia";
          };
        };
        "<leader>fyk" = {
          action = telescopeSymbolsBinding "kaomoji";
          options = {
            desc = "[k]aomoji";
          };
        };
        "<leader>fyl" = {
          action = telescopeSymbolsBinding "latex";
          options = {
            desc = "[l]atex";
          };
        };
        "<leader>fym" = {
          action = telescopeSymbolsBinding "math";
          options = {
            desc = "[m]ath";
          };
        };
        "<leader>fyn" = {
          action = telescopeSymbolsBinding "nerd";
          options = {
            desc = "[n]erd";
          };
        };
      });
  };
}
