{ pkgs, ... }:
{
  # AI auto-completion
  # https://github.com/supermaven-inc/supermaven-nvim
  config = {
    # TODO: which keymaps are best?
    # TODO: should I register this as a cmp source?
    extraConfigLua = # lua
      ''
        require("supermaven-nvim").setup({})
      '';
    extraPlugins = [ pkgs.vimPlugins.supermaven-nvim ];
  };
}
