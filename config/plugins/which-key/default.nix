{ ... }:
{
  # keybindings assistant
  # https://github.com/folke/which-key.nvim/
  # https://nix-community.github.io/nixvim/plugins/which-key/index.html
  config = {
    plugins.which-key.enable = true;

    # Stolen from:
    # https://github.com/Alexnortung/nollevim/blob/fcc35456c567c6108774e839d617c97832217e67/config/which-key.nix
    extraConfigLuaPost = # lua
      ''
        local wk = require("which-key")
        wk.setup {
        }

        wk.add {
          { "<leader>f", group = "[f]ind", icon = "", },
          { "<leader>fy", group = "s[y]mbol", icon = "", },
          { "<leader>h", group = "[h]unk", icon = "", },
          { "<leader>l", group = "[l]sp", icon = "󰁨", },
          { "<leader>n", group = "[n]ode", icon = "", },
          { "<leader>o", group = "[o]rg", icon = "", },
          { "<leader>s", group = "fla[s]h", icon = "󱐋", },
          { "<leader>t", group = "[t]oggle", icon = "", },
        }
      '';
  };
}
