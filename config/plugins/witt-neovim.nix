{ pkgs, ... }:
let
  witt-neovim = pkgs.vimUtils.buildVimPlugin {
    name = "witt-neovim";
    src = pkgs.fetchFromGitHub {
      owner = "xav-ie";
      repo = "witt-neovim";
      rev = "deac52e7d5aace5dec6b010644615dfbc5425c21";
      hash = "sha256-9kE3vjhDpdOu6N6AqMY4JqFTKcg5qRezxOe0i6ItfCU=";
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
