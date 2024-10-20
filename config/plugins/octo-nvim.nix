{ pkgs, ... }:
let
  octo-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "octo.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "pwntester";
      repo = "octo.nvim";
      rev = "5646539320cd62af6ff28f48ec92aeb724c68e18";
      hash = "sha256-EK05b72/ekNcA7RBauiKZ27/rF4YX6IXnzRpODzXduI=";
    };
  };
in
{
  # review issues and PRs in nvim
  # https://github.com/pwntester/octo.nvim
  config = {
    extraConfigLua = # lua
      ''
        require('octo').setup({
          suppress_missing_scope = {
            projects_v2 = true,
          },
        })
      '';
    extraPlugins = [ octo-nvim ];
  };
}
