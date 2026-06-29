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
    # No load trigger of its own: colorful-menu exists only to render blink's
    # completion menu, so blink force-loads it via `trigger_load` in its own
    # `before` hook (see blink-cmp/default.nix). This spec just defines how to
    # load + set it up when that trigger fires.
    plugins.lz-n.plugins = [
      {
        "__unkeyed-1" = "colorful-menu.nvim";
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
