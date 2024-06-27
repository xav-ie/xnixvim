{ ... }:

{

  plugins.which-key.enable = true;

  # Stolen from:
  # https://github.com/Alexnortung/nollevim/blob/fcc35456c567c6108774e839d617c97832217e67/config/which-key.nix
  extraConfigLuaPost = # lua
    ''
      local wk = require("which-key")
      wk.setup {
      }

      wk.register {
          ["<leader>"] = {
              -- TODO: move into specific plugin?
              f = {
                  name = "+[f]ind",
                  y = {
                    name = "+s[y]mbol",
                  },
              },
              l = {
                  name = "+[l]sp",
              },
              n = {
                  name = "+[n]ode",
              },
              o = {
                  name = "+[o]rg",
              },
              s = {
                  name = "+fla[s]h",
              },
          },
      }
    '';
}
