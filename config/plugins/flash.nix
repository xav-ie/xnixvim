{ ... }:
{
  config = {
    plugins.flash = {
      enable = true;
      # auto-jump when there is only one match
      settings.jump.autojump = true;
    };
  };
}
