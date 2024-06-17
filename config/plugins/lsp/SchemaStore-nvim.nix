{ pkgs, ... }:
let
  SchemaStore-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "SchemaStore.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "b0o";
      repo = "SchemaStore.nvim";
      rev = "cf82be744f4dba56d5d0c13d7fe429dd1d4c02e7";
      hash = "sha256-bAsSHBdxdwfHZ3HiU/wyeoS/FiQNb3a/TB2lQOz/glA=";
    };
  };
in
{
  extraPlugins = [ SchemaStore-nvim ];
}
