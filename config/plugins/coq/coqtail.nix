{ pkgs, inputs, ... }:
let
  coqtail = pkgs.vimUtils.buildVimPlugin {
    name = "Coqtail";
    src = inputs.coqtail;
  };
in
{
  # Interactive Coq Proofs in Vim
  # https://github.com/whonore/Coqtail
  config = {
    extraPlugins = [ coqtail ];
  };
}
