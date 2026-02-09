{ pkgs, ... }:
{
  # beautiful, performant scrollbar
  # https://github.com/dstein64/nvim-scrollview
  config = {
    extraPlugins = [
      {
        plugin = pkgs.vimPlugins.nvim-scrollview;
        optional = true;
      }
    ];
    plugins.lz-n.plugins = [
      {
        "__unkeyed-1" = "nvim-scrollview";
        event = [ "BufReadPost" ];
        after = # lua
          ''
            function()
              vim.g.scrollview_winblend = 80
              vim.g.scrollview_winblend_gui = 80
              require('scrollview').setup({
                signs_on_startup = {},
              })
            end
          '';
      }
    ];
    highlight = {
      ScrollView = {
        bg = "White";
      };
    };
  };
}
