{ pkgs, inputs, ... }:
let
  octo-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "octo.nvim";
    inherit (inputs.octo-nvim) src;
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
