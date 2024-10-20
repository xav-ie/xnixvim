{ pkgs, ... }:
{
  # beautiful, performant scrollbar
  # https://github.com/dstein64/nvim-scrollview
  config = {
    extraPlugins = with pkgs.vimPlugins; [
      nvim-scrollview
    ];
    extraConfigLua = # lua
      ''
        vim.g.scrollview_winblend = 80
        vim.g.scrollview_winblend_gui = 80
        require('scrollview').setup({
          signs_on_startup = {},
        })
      '';
    highlight = {
      ScrollView = {
        bg = "White";
      };
    };
  };
}
