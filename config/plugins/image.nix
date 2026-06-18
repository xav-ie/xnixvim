{
  pkgs,
  inputs,
  config,
  ...
}:
{
  config = {
    # original: https://github.com/3rd/image.nvim
    # my fork: https://github.com/xav-ie/image.nvim
    # https://nix-community.github.io/nixvim/plugins/image
    plugins.image = {
      enable = true;
      # ~7ms of requires (image + utils + tmux probe) off the critical path.
      # integrations = {} below means nothing hooks markdown on load, so the
      # plugin only acts on demand — safe to defer until the UI is up.
      lazyLoad.enable = config.lazyLoad.enable;
      lazyLoad.settings.event = "DeferredUIEnter";
      package = pkgs.vimPlugins.image-nvim.overrideAttrs (_old: {
        src = pkgs.lib.cleanSourceWith {
          src = inputs.image-nvim;
          filter =
            path: _type:
            # Exclude non-module files that fail the require check
            baseNameOf path != "minimal-setup.lua";
        };
      });
      settings = {
        backend = "kitty";
        kitty_method = "normal";
        integrations = { };
        tmux_show_only_in_active_window = true;
        # Don't shrink images to a fraction of the window height: render at
        # natural size and let the renderer's crop logic clip when the window
        # is too short (otherwise a short window scales the image way down).
        max_height_window_percentage.__raw = "false";
      };
    };
    # Replace a re-rendered image (e.g. himalaya progressive's 2nd pass) in place
    # instead of clearing then redrawing, to avoid the flash. Set via a global
    # (nixvim drops unknown plugins.image.settings keys); runtime-toggleable with
    # :lua vim.g.image_flicker_free_rerender = false
    extraConfigLua = ''
      vim.g.image_flicker_free_rerender = true
    '';
  };
}
