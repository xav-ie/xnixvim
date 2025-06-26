{ config, ... }:
{
  # https://github.com/folke/lazydev.nvim
  # https://nix-community.github.io/nixvim/plugins/lazydev
  config = {
    # automatic type resolution for faster lua_ls
    plugins.lazydev = {
      enable = true;
      settings.library = [
        config.package
      ];
      # TODO: how to resolve plugins' lua?
      #++ (map (p: if builtins.hasAttr "plugin" p then p.plugin else p) config.extraPlugins);
    };

  };
}
