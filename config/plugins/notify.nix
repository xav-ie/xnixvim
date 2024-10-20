{ ... }:
{
  # pretty notifications
  # https://github.com/rcarriga/nvim-notify
  # https://nix-community.github.io/nixvim/plugins/notify/index.html
  config = {
    plugins.notify = {
      enable = true;
      backgroundColour = "#00000000";
      fps = 60;
    };
  };
}
