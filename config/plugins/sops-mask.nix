{ pkgs, ... }:
let
  sops-mask = pkgs.vimUtils.buildVimPlugin {
    name = "sops-mask";
    src = ../custom-plugins/sops-mask;
  };
in
{
  # Hide secret values in sops-decrypted buffers; only the cursor line and the
  # last 4 characters of each value are readable. `:SopsMaskToggle` to unmask.
  config = {
    extraConfigLua = # lua
      ''
        require('sops-mask').setup()
      '';
    extraPlugins = [ sops-mask ];
  };
}
