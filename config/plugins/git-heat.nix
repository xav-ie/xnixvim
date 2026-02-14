{ pkgs, ... }:
let
  git-heat = pkgs.vimUtils.buildVimPlugin {
    name = "git-heat";
    src = ../custom-plugins/git-heat;
  };
in
{
  config = {
    extraConfigLua = ''require('git-heat').setup()'';
    extraPlugins = [ git-heat ];
  };
}
