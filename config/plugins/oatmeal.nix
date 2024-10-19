{ pkgs, ... }:
let
  oatmeal-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "oatmeal.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "dustinblackman";
      repo = "oatmeal.nvim";
      rev = "c8cdd0a182cf77f88ea5fa4703229ddb3f47c1f7";
      hash = "sha256-YqGOAZ8+KRYJbOIVHD9yreL7ZvBwbWeKwsM/oV6r3Ic=";
    };
  };
in
{
  config = {
    extraConfigLua = # lua
      ''
        require('oatmeal').setup({backend='ollama', model='codestral:latest'})
      '';
    extraPlugins = [ oatmeal-nvim ];
  };
}
