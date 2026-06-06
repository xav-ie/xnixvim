{
  config,
  lib,
  ...
}:
{
  # Syntax-aware text objects: select/move/swap by AST node.
  # https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  # https://nix-community.github.io/nixvim/plugins/treesitter-textobjects
  config = {
    # On nvim-treesitter's `main` rewrite (the branch this config tracks, see
    # treesitter.nix) textobjects no longer reads keymaps from setup() — they
    # must be defined via the keymap API calling the per-module functions. The
    # nixvim module only puts the package on the rtp and forwards settings; the
    # actual keymaps live below.
    plugins.treesitter-textobjects = {
      enable = true;
      lazyLoad.enable = config.lazyLoad.enable;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
      settings = {
        select.lookahead = true;
        move.set_jumps = true; # store moves in the jumplist
      };
    };

    keymaps =
      let
        # select_textobject jumps to / selects the node; works in operator
        # (daf, cif…) and visual (vaf) modes.
        sel =
          obj: # lua
          ''
            function()
              require('nvim-treesitter-textobjects.select').select_textobject('${obj}', 'textobjects')
            end
          '';
        move =
          fn: obj: # lua
          ''
            function()
              require('nvim-treesitter-textobjects.move').${fn}('${obj}', 'textobjects')
            end
          '';
        swap =
          fn: obj: # lua
          ''
            function()
              require('nvim-treesitter-textobjects.swap').${fn}('${obj}')
            end
          '';
        selectKey = key: obj: desc: {
          mode = [
            "x"
            "o"
          ];
          inherit key;
          action.__raw = sel obj;
          options.desc = desc;
        };
        moveKey = key: fn: obj: desc: {
          mode = [
            "n"
            "x"
            "o"
          ];
          inherit key;
          action.__raw = move fn obj;
          options.desc = desc;
        };
        swapKey = key: fn: obj: desc: {
          mode = "n";
          inherit key;
          action.__raw = swap fn obj;
          options.desc = desc;
        };
      in
      lib.nixvim.keymaps.mkKeymaps { options.silent = true; } [
        # ── select ──────────────────────────────────────────────────────────
        (selectKey "af" "@function.outer" "a function")
        (selectKey "if" "@function.inner" "inner function")
        (selectKey "ac" "@class.outer" "a class")
        (selectKey "ic" "@class.inner" "inner class")
        (selectKey "aa" "@parameter.outer" "an argument")
        (selectKey "ia" "@parameter.inner" "inner argument")
        # ── move ────────────────────────────────────────────────────────────
        (moveKey "]f" "goto_next_start" "@function.outer" "Next function start")
        (moveKey "[f" "goto_previous_start" "@function.outer" "Prev function start")
        (moveKey "]F" "goto_next_end" "@function.outer" "Next function end")
        (moveKey "[F" "goto_previous_end" "@function.outer" "Prev function end")
        (moveKey "]a" "goto_next_start" "@parameter.inner" "Next argument")
        (moveKey "[a" "goto_previous_start" "@parameter.inner" "Prev argument")
        # ── swap (under the [n]ode group) ───────────────────────────────────
        (swapKey "<leader>na" "swap_next" "@parameter.inner" "[n]ode: swap argument with next")
        (swapKey "<leader>nA" "swap_previous" "@parameter.inner" "[n]ode: swap argument with prev")
      ];
  };
}
