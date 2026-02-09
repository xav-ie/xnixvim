{ pkgs, ... }:
let
  markdown-table-sorter = pkgs.vimUtils.buildVimPlugin {
    name = "markdown-table-sorter";
    src = ../custom-plugins/markdown-table-sorter;
    # treesitter is needed for the build-time require check but managed
    # by lz.n at runtime
    dependencies = [ ];
    nativeCheckInputs = [ pkgs.vimPlugins.nvim-treesitter ];
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
