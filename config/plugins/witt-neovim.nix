{ pkgs, inputs, ... }:
let
  witt-neovim = pkgs.vimUtils.buildVimPlugin {
    name = "witt-neovim";
    src = inputs.witt-neovim;
  };
in
{
  # ^? support in nvim
  # https://github.com/typed-rocks/witt-neovim
  config = {
    extraConfigLua = # lua
      ''
        require('witt')
      '';
    extraPlugins = [ witt-neovim ];
  };
}
