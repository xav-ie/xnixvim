{ pkgs, ... }:
{
  # https://github.com/petertriho/nvim-scrollbar
  config = {
    extraPlugins = with pkgs.vimPlugins; [
      nvim-scrollbar
    ];
    extraConfigLua = # lua
      ''
        require('scrollbar').setup({
          handle = {
            color = '#333333',
          },
          handlers = {
            cursor = false,
          },
        })
      '';
  };
}
