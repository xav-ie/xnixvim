{
  config,
  lib,
  pkgs,
  ...
}:
let
  augment-vim = pkgs.vimPlugins.augment-vim.overrideAttrs {
    version = "2025-03-18";
    src = pkgs.fetchFromGitHub {
      owner = "augmentcode";
      repo = "augment.vim";
      rev = "97418c9dfc1918fa9bdd23863ea3d2e49130727f";
      hash = "sha256-ekexQ2tI/GxEbNHhxF0fj0vwIH3+H0joSayL9vmlBOs=";
    };
  };
  cfg = config.programs.augment;
in
{
  # AI auto-completion
  # https://github.com/augmentcode/augment.vim
  options.programs.augment = {
    enabled = lib.mkEnableOption "augment";
  };

  config = lib.mkIf cfg.enabled {
    extraPackages = [ pkgs.nodejs ];
    extraPlugins = [ augment-vim ];
  };
}
