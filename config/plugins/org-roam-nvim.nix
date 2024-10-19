{ pkgs, ... }:
let
  org-roam-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "org-roam.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "chipsenkbeil";
      repo = "org-roam.nvim";
      rev = "0.1.0";
      hash = "sha256-n7GrZrM5W7QvM7805Li0VEBKc23KKbrxG3voL3otpLw=";
    };
  };
in
{
  config = {
    extraConfigLua = # lua
      ''
        require("org-roam").setup({
          directory = "~/Notes",
        })
      '';
    extraPlugins = [ org-roam-nvim ];
  };
}
