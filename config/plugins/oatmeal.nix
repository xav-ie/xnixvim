{ pkgs, inputs, ... }:
let
  oatmeal-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "oatmeal.nvim";
    src = inputs.oatmeal;
  };
in
{
  # AI assistant
  config = {
    extraConfigLua = # lua
      ''
        require('oatmeal').setup({backend='ollama', model='codestral:latest'})
      '';
    extraPlugins = [ oatmeal-nvim ];
  };
}
