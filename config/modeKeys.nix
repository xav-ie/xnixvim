{ lib, ... }:
let
  modeKeys =
    mode:
    lib.attrsets.mapAttrsToList (
      key: action:
      { inherit key mode; } // (if builtins.isString action then { inherit action; } else action)
    );
in
{
  inherit modeKeys;
  nm = modeKeys [ "n" ];
  vs = modeKeys [ "v" ];
  im = modeKeys [ "i" ];
  c = modeKeys [ "c" ];
  t = modeKeys [ "t" ];
  nxo = modeKeys [
    "n"
    "x"
    "o"
  ];
}
