{ pkgs, inputs, ... }:
let
  SchemaStore-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "SchemaStore.nvim";
    src = inputs.schemastore-nvim;
  };
in
{
  # JSON schemas for Neovim
  # https://github.com/b0o/SchemaStore.nvim
  config = {
    extraPlugins = [ SchemaStore-nvim ];
  };
}
