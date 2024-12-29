{ pkgs, inputs, ... }:
let
  oil-git-status = pkgs.vimUtils.buildVimPlugin {
    name = "oil-git-status.nvim";
    src = inputs.oil-git-status;
    dependencies = [ pkgs.vimPlugins.oil-nvim ];
  };
in
{
  # adds git status to oil buffers
  # https://github.com/refractalize/oil-git-status.nvim
  config = {
    extraConfigLua = # lua
      ''
        require('oil-git-status').setup()
      '';
    extraPlugins = [ oil-git-status ];
  };
}
