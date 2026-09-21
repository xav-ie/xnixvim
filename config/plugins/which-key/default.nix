{ pkgs, ... }:
{
  # keybindings assistant
  # https://github.com/folke/which-key.nvim/
  # https://nix-community.github.io/nixvim/plugins/which-key
  config = {
    plugins.which-key = {
      enable = true;
      settings.delay = 1000;

      # Upstream keeps a 50ms uv timer running for the lifetime of the process
      # to work around ModeChanged not always firing (folke/which-key.nvim#787).
      # It never stops, so every nvim instance wakes 20x/sec forever, focused or
      # not. The patch swaps it for a `SafeState` + `ModeChanged` autocmd, which
      # runs the identical check at the same moment but costs nothing when idle.
      package = pkgs.vimPlugins.which-key-nvim.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./event-driven-mode-check.patch ];
      });
    };

    # Stolen from:
    # https://github.com/Alexnortung/nollevim/blob/fcc35456c567c6108774e839d617c97832217e67/config/which-key.nix
    extraConfigLuaPost = # lua
      ''
        local wk = require("which-key")

        wk.add {
          { "<leader>c", group = "[c]opy", icon = " ", },
          { "<leader>d", group = "[d]iagnostic", icon = " ", },
          { "<leader>f", group = "[f]ind", icon = " ", },
          { "<leader>fy", group = "s[y]mbol", icon = " ", },
          { "<leader>h", group = "[h]unk", icon = " ", },
          { "<leader>l", group = "[l]sp", icon = "󰁨 ", },
          { "<leader>n", group = "[n]ode", icon = " ", },
          { "<leader>o", group = "[o]rg", icon = " ", },
          { "<leader>O", group = "[O]bsidian", icon = "󰠮 ", },
          { "<leader>r", group = "[r]efactor", icon = "󰢱 ", },
          { "<leader>s", group = "fla[s]h", icon = " ", },
          { "<leader>t", group = "[t]oggle", icon = " ", },
          { "<leader>y", group = "[y]ank", icon = " ", },
        }
      '';
  };
}
