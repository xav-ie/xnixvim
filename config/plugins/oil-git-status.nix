{ pkgs, ... }:
let
  oil-git-status = pkgs.vimUtils.buildVimPlugin {
    name = "oil-git-status.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "refractalize";
      repo = "oil-git-status.nvim";
      rev = "839a1a287f5eb3ce1b07b50323032398e63f7ffa";
      hash = "sha256-pTAvkJPmT3eD3XWrYl6nyKSzeRFEHOi8iDCamF1D1Cg=";
    };
  };
in
{
  # adds git status to oil buffers
  # https://github.com/refractalize/oil-git-status.nvim
  config = {
    extraConfigLua = # lua
      ''
        require('oil-git-status').setup()
      '';
    extraPlugins = [ oil-git-status ];
  };
}
