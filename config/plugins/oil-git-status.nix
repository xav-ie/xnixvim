{
  config,
  pkgs,
  inputs,
  ...
}:
let
  oil-git-status = pkgs.vimUtils.buildVimPlugin {
    name = "oil-git-status.nvim";
    src = inputs.oil-git-status;
    dependencies =
      with pkgs.vimPlugins;
      [
        oil-nvim
      ]
      ++ (if config.plugins.oil.lazyLoad.enable then [ lz-n ] else [ ]);
  };
in
{
  # adds git status to oil buffers
  # https://github.com/refractalize/oil-git-status.nvim
  config = {
    extraConfigLua =
      if config.plugins.oil.lazyLoad.enable then
        # lua
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
        ''
      # lua
      else
        ''
          require("oil-git-status").setup()
        '';

    extraPlugins = [ oil-git-status ];
  };
}
