# xdusk: the custom colorscheme, now maintained in its own flake
# (`path:/Users/x/Projects/xdusk`). The Neovim plugin is generated there from a
# shared palette that also drives the VS Code theme, so the two editors stay in
# lockstep. To change colors, edit palette.nix in the xdusk flake and
# `nix flake update xdusk` here.
{ pkgs, inputs, ... }:
{
  config = {
    extraPlugins = [ inputs.xdusk.packages.${pkgs.stdenv.hostPlatform.system}.nvim ];
    colorscheme = "xdusk";
  };
}
