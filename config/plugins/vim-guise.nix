{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  vim-guise = pkgs.vimUtils.buildVimPlugin {
    name = "vim-guise";
    src = inputs.vim-guise;
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
