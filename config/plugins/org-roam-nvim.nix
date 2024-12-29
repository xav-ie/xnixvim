{ pkgs, inputs, ... }:
let
  org-roam-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "org-roam.nvim";
    src = inputs.org-roam-nvim;
  };
in
{
  # Actual org-roam in neovim
  # https://github.com/chipsenkbeil/org-roam.nvim
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
