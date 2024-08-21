{ pkgs, ... }:
let
  SortGroup = pkgs.vimUtils.buildVimPlugin {
    name = "SortGroup.vim";
    src = pkgs.fetchurl {
      url = "https://gist.githubusercontent.com/PeterRincker/582ea9be24a69e6dd8e237eb877b8978/raw/782e8e3026a55c31ac0dabaafe3b058ea2a29812/SortGroup.vim";
      name = "SortGroup.vim";
      sha256 = "sha256-TmpOTKx+TYJ6vPn9mPCZj8x1cnBefaDB9icatnl8ELY=";
    };
    sourceRoot = ".";
    unpackPhase = ''
      runHook preUnpack

      echo "GOODBYE"
      install -Dm755 $src $sourceRoot/SortGroup.vim

      runHook postUnpack
    '';
  };
in
{
  # I have not idea how to properly require this
  # TODO: read up on requiring .vim files
  # extraConfigLua = # lua
  #   ''
  #     require('sort_group').setup()
  #   '';
  extraPlugins = [ SortGroup ];
}
