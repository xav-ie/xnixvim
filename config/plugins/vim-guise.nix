{ pkgs, lib, ... }:

let
  vim-guise = pkgs.vimUtils.buildVimPlugin {
    name = "vim-guise";
    src = pkgs.fetchFromGitHub {
      owner = "lambdalisue";
      repo = "vim-guise";
      rev = "1759cc936583490af76c36e0a25546329b2b9921";
      hash = "sha256-srtcPjG+TPgHvqdIXPg3n99Rwtck/N1a+EzURcXKscw=";
    };
    dependencies = with pkgs.vimPlugins; [ denops-vim ];
  };
in
{
  # `nvim` inside a terminal buffer or otherwise will no
  # longer recursively create a new `nvim` process. It will
  # create a new buffer in current instance.
  # https://github.com/lambdalisue/vim-guise/tree/main
  config = {
    extraPlugins = [
      (lib.mkBefore pkgs.vimPlugins.denops-vim)
      vim-guise
    ];
    extraConfigLua = # lua
      ''
        vim.g.guise_edit_opener = "edit"
      '';
  };
}
