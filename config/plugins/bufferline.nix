{ config, ... }:
{
  config = {
    # TODO: consider barbar.enable instead
    # https://github.com/akinsho/bufferline.nvim
    # https://nix-community.github.io/nixvim/plugins/bufferline
    # tabs
    plugins.bufferline = {
      enable = true;
      lazyLoad.settings.event = "BufEnter";
      lazyLoad.enable = config.lazyLoad.enable;
      settings = {
        options = {
          separator_style = "thin";
          show_buffer_close_icons = false;
          indicator.icon = "▌";
          tab_size = 0;
        };
      };
    };
  };
}
