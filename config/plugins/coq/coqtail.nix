{ pkgs, ... }:
let
  coqtail = pkgs.vimUtils.buildVimPlugin {
    name = "Coqtail";
    src = pkgs.fetchFromGitHub {
      owner = "whonore";
      repo = "Coqtail";
      rev = "c1dc30666c957815b012ae67e8e61de6b48ecf86";
      hash = "sha256-+7uBuycYKHxpUWVtq6V0/59bH5p8P5AOTMWl7LvUGZ4=";
    };
  };
in
{
  config = {
    extraPlugins = [ coqtail ];
  };
}
