{
  config,
  lib,
  ...
}:
{
  # Yank ring + history. Records every yank (persisted via ShaDa), highlights
  # put/yank regions, and lets you cycle through previous yanks after a paste.
  # https://github.com/gbprod/yanky.nvim
  # https://nix-community.github.io/nixvim/plugins/yanky
  config = {
    plugins.yanky = {
      enable = true;
      lazyLoad.enable = config.lazyLoad.enable;
      # Remaps p/y below need the plugs available, so load on first edit.
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
      settings = {
        # Persist the ring across sessions without the sqlite dependency.
        ring.storage = "shada";
        highlight = {
          on_put = true;
          on_yank = true;
          timer = 200;
        };
      };
    };

    keymaps = lib.nixvim.keymaps.mkKeymaps { options.silent = true; } [
      # Route yanks/puts through yanky so the ring stays populated. The OSC52
      # clipboard sync (extraConfigLua.nix) hooks TextYankPost independently and
      # is unaffected.
      {
        mode = [
          "n"
          "x"
        ];
        key = "y";
        action = "<Plug>(YankyYank)";
        options.desc = "Yank (yanky)";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "p";
        action = "<Plug>(YankyPutAfter)";
        options.desc = "Put after (yanky)";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "P";
        action = "<Plug>(YankyPutBefore)";
        options.desc = "Put before (yanky)";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "gp";
        action = "<Plug>(YankyGPutAfter)";
        options.desc = "Put after, cursor after (yanky)";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "gP";
        action = "<Plug>(YankyGPutBefore)";
        options.desc = "Put before, cursor after (yanky)";
      }
      # Cycle through the ring after a put. <C-n>/<C-p> are taken (tree-sitter
      # node-select / completion), so use Alt to avoid collisions.
      {
        mode = "n";
        key = "<M-p>";
        action = "<Plug>(YankyPreviousEntry)";
        options.desc = "Yank ring: previous entry";
      }
      {
        mode = "n";
        key = "<M-n>";
        action = "<Plug>(YankyNextEntry)";
        options.desc = "Yank ring: next entry";
      }
      # Browse the full yank history (telescope picker via the YankyRingHistory
      # command).
      {
        mode = "n";
        key = "<leader>yh";
        action = "<cmd>YankyRingHistory<CR>";
        options.desc = "[y]ank: history";
      }
    ];
  };
}
