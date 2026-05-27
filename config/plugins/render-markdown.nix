{ config, ... }:
{
  config = {
    # https://nix-community.github.io/nixvim/plugins/render-markdown
    # https://github.com/MeanderingProgrammer/render-markdown.nvim
    plugins.render-markdown = {
      enable = true;
      lazyLoad.settings.ft = "markdown";
      lazyLoad.enable = config.lazyLoad.enable;
      settings = {
        sign.enabled = false;
        heading.border = true;
        # heading.border_virtual = true;
        heading.position = "inline";
        pipe_table.preset = "round";
      };
    };
    # Markdown heading / code / bullet colors were extracted into the xdusk
    # colorscheme (custom-plugins/xdusk).
  };
}
