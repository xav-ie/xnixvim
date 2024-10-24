{ ... }:
{
  # https://github.com/folke/flash.nvim/
  # https://nix-community.github.io/nixvim/plugins/flash
  config = {
    plugins.flash = {
      enable = true;
      # auto-jump when there is only one match
      settings.jump.autojump = true;
    };
  };
}
