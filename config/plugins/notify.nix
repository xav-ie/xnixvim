{ config, ... }:
{
  # pretty notifications
  # https://github.com/rcarriga/nvim-notify
  # https://nix-community.github.io/nixvim/plugins/notify
  config = {
    plugins.notify = {
      enable = true;
      lazyLoad.enable = config.lazyLoad.enable;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        background_colour = "#00000000";
        fps = 60;
        merge_duplicates = true;
      };
    };
  };
}
