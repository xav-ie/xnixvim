{ pkgs, ... }:
{
  # variable-size, treesitter-highlighted completion items for blink.cmp
  # https://github.com/xzbdmw/colorful-menu.nvim
  config = {
    extraPlugins = [
      {
        plugin = pkgs.vimPlugins.colorful-menu-nvim;
        optional = true;
      }
    ];
    plugins.lz-n.plugins = [
      {
        "__unkeyed-1" = "colorful-menu.nvim";
        event = "InsertEnter";
        after = # lua
          ''
            function()
              require('colorful-menu').setup({})
            end
          '';
      }
    ];
  };
}
