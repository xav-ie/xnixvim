{ pkgs, inputs, ... }:
let
  tabscope-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "tabscope.nvim";
    src = inputs.tabscope-nvim;
  };
in
{
  # manage buffers to be tab-scoped
  # https://github.com/backdround/tabscope.nvim
  # THIS PLUGIN IS AMAZING!!!
  config = {
    extraConfigLua = # lua
      ''
        require('tabscope').setup({})
        vim.keymap.set('n', '<leader>x', require('tabscope').remove_tab_buffer, { desc = "Remove Tab Buffer" })
      '';
    extraPlugins = [ tabscope-nvim ];
  };
}
