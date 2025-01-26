{ pkgs, inputs, ... }:
let
  oil-git-status = pkgs.vimUtils.buildVimPlugin {
    name = "oil-git-status.nvim";
    src = inputs.oil-git-status;
    dependencies = with pkgs.vimPlugins; [
      oil-nvim
      # TODO: a better way?
      lz-n
    ];
  };
in
{
  # adds git status to oil buffers
  # https://github.com/refractalize/oil-git-status.nvim
  config = {
    extraConfigLua = # lua
      ''
        require("lz.n").load({
          {
            "oil-git-status.nvim",
            after = function()
              require("oil-git-status").setup()
            end,
            ft = "oil",
          },
        })
      '';

    extraPlugins = [ oil-git-status ];
  };
}
