{ pkgs, ... }:
let
  witt-neovim = pkgs.vimUtils.buildVimPlugin {
    name = "witt-neovim";
    src = pkgs.fetchFromGitHub {
      owner = "xav-ie";
      repo = "witt-neovim";
      rev = "4020181341465dc24014afc872a5df0a60453c4c";
      hash = "sha256-mpLG/6n42CzU428ali2rQ6rZBf/NvVjFF0r/Skda/2w=";
    };
  };
in
{
  extraConfigLua = # lua
    ''
      require('witt')
    '';
  extraPlugins = [ witt-neovim ];
}
