{ pkgs, ... }:
let
  markdown-table-sorter = pkgs.vimUtils.buildVimPlugin {
    name = "markdown-table-sorter";
    src = ../custom-plugins/markdown-table-sorter;
    dependencies = [ pkgs.vimPlugins.nvim-treesitter ];
  };
in
{
  config = {
    extraConfigLua = # lua
      ''
        -- TODO: improve docs and package
        require('markdown-table-sorter')
      '';
    extraPlugins = [ markdown-table-sorter ];
  };
}
