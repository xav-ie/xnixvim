{ pkgs, ... }:
{
  # automatic env updates
  # https://github.com/direnv/direnv.vim/
  # https://nix-community.github.io/nixvim/plugins/direnv
  config = {
    extraPlugins = [
      {
        plugin = pkgs.vimPlugins.direnv-vim;
        optional = true;
      }
    ];
    plugins.lz-n.plugins = [
      {
        "__unkeyed-1" = "direnv.vim";
        event = [ "DeferredUIEnter" ];
      }
    ];
  };
}
