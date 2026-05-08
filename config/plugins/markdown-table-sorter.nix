{ pkgs, ... }:
let
  markdown-table-sorter = pkgs.vimUtils.buildVimPlugin {
    name = "markdown-table-sorter";
    src = ../custom-plugins/markdown-table-sorter;
    dependencies = [ ];
  };
in
{
  config = {
    extraConfigLua = # lua
      ''
        vim.api.nvim_create_autocmd("BufReadPost", {
          once = true,
          callback = function()
            require('markdown-table-sorter')
          end,
        })
      '';
    extraPlugins = [ markdown-table-sorter ];
  };
}
