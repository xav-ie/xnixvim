{ pkgs, ... }:
let
  orgmode = pkgs.vimUtils.buildVimPlugin {
    name = "orgmode";
    src = pkgs.fetchFromGitHub {
      owner = "nvim-orgmode";
      repo = "orgmode";
      rev = "0.3.4";
      hash = "sha256-SmofuYt4fLhtl5qedYlmCRgOmZaw3nmlnMg0OMzyKnM=";
    };
  };
in
{
  extraConfigLua = # lua
    ''
      require("orgmode").setup({})
    '';
  extraPlugins = [ orgmode ];
}
