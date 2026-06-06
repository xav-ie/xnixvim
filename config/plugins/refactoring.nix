{
  config,
  lib,
  ...
}:
{
  # Treesitter-based refactoring (Martin Fowler operations) + debug-print
  # helpers. Extract function/variable partly overlaps TS LSP code actions; the
  # unique wins here are the language-agnostic debug printf/print-var/cleanup.
  # https://github.com/ThePrimeagen/refactoring.nvim
  # https://nix-community.github.io/nixvim/plugins/refactoring
  config = {
    plugins.refactoring = {
      enable = true;
      # Route the extract/inline picker through telescope-ui-select.
      enableTelescope = true;
      lazyLoad.enable = config.lazyLoad.enable;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
    };

    keymaps = lib.nixvim.keymaps.mkKeymaps { options.silent = true; } [
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>rr";
        action.__raw = # lua
          ''
            function() require('refactoring').select_refactor() end
          '';
        options.desc = "[r]efactor: select (extract/inline)";
      }
      {
        mode = "n";
        key = "<leader>rp";
        action.__raw = # lua
          ''
            function() require('refactoring').debug.printf({ below = false }) end
          '';
        options.desc = "[r]efactor: debug printf";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>rv";
        action.__raw = # lua
          ''
            function() require('refactoring').debug.print_var() end
          '';
        options.desc = "[r]efactor: debug print var";
      }
      {
        mode = "n";
        key = "<leader>rc";
        action.__raw = # lua
          ''
            function() require('refactoring').debug.cleanup({}) end
          '';
        options.desc = "[r]efactor: debug cleanup";
      }
    ];
  };
}
