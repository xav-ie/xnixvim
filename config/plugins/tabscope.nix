{ pkgs, ... }:
let
  tabscope-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "tabscope.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "backdround";
      repo = "tabscope.nvim";
      # TODO: pin
      rev = "main";
      hash = "sha256-eM0N2fyiX78/MoP8a6T/nsvtkMRprK/lJp9Wfm83yv4=";
    };
  };
in
{
  # THIS PLUGIN IS AMAZING!!!
  extraConfigLua = # lua
    ''
      require('tabscope').setup({})
      vim.keymap.set('n', '<leader>x', require('tabscope').remove_tab_buffer, { desc = "Remove Tab Buffer" })
    '';
  extraPlugins = [ tabscope-nvim ];
}
