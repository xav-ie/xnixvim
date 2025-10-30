{ config, pkgs, ... }:
{
  # colors in Neovim
  # https://github.com/catgoose/nvim-colorizer.lua/
  # https://nix-community.github.io/nixvim/plugins/colorizer
  config = {
    plugins.colorizer = {
      enable = true;
      package = pkgs.vimPlugins.nvim-colorizer-lua.overrideAttrs (_: {
        src = pkgs.fetchFromGitHub {
          owner = "xav-ie";
          repo = "nvim-colorizer.lua";
          rev = "454acbb74b3220dd26e5703b948e34573080a9ee";
          sha256 = "sha256-1faAhmHrYhCyeVc4vRaRWC1OW38POjTEwORjtnRdoV4=";
        };
      });
      lazyLoad.settings.event = "BufEnter";
      lazyLoad.enable = config.lazyLoad.enable;
      settings = {
        user_default_options = {
          css = true;
          AARRGGBB = true;
          sass = {
            enable = true;
            parsers = [ "css" ];
          };
          tailwind = true;
          tailwind_opts = {
            update_names = true;
          };
          xterm = true;
        };
      };
    };
  };
}
