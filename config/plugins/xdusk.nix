{ pkgs, ... }:
let
  # xdusk: the custom colorscheme, extracted from the former base16 palette
  # plus all the per-plugin highlight tuning. Self-contained Lua (no base16
  # dependency); src lives in custom-plugins/xdusk and can be lifted into its
  # own repo unchanged.
  xdusk = pkgs.vimUtils.buildVimPlugin {
    name = "xdusk";
    src = ../custom-plugins/xdusk;
  };
in
{
  config = {
    extraPlugins = [ xdusk ];
    colorscheme = "xdusk";
  };
}
