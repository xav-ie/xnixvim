{ ... }:
{
  # colors in Neovim
  # https://github.com/norcalli/nvim-colorizer.lua
  # https://nix-community.github.io/nixvim/plugins/nvim-colorizer
  config = {
    plugins.colorizer = {
      enable = true;
      settings = {
        user_default_options = {
          RGB = true;
          RRGGBB = true;
          names = true;
          RRGGBBAA = true;
          rgb_fn = true;
          hsl_fn = true;
          css = true;
          css_fn = true;
          tailwind = true;
        };
      };
    };
  };
}
