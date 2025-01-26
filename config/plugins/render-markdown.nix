_: {
  config = {
    # https://nix-community.github.io/nixvim/plugins/render-markdown
    # https://github.com/MeanderingProgrammer/render-markdown.nvim
    plugins.render-markdown = {
      enable = true;
      lazyLoad.settings.ft = "markdown";
      settings = {
        sign.enabled = false;
        heading.border = true;
        # heading.border_virtual = true;
        heading.position = "inline";
        pipe_table.preset = "round";
      };
    };
    highlight =
      let
        headerBg = "#200030";
        headerFg = "#9a5feb";
      in
      {
        # Prevent colors from changing when switching between editing
        # and concealing
        RenderMarkdownBullet.fg = "#E07153";
        RenderMarkdownCode.bg = "#200020";
        RenderMarkdownH1Bg.bg = headerBg;
        RenderMarkdownH2Bg.bg = headerBg;
        RenderMarkdownH3Bg.bg = headerBg;
        RenderMarkdownH4Bg.bg = headerBg;
        RenderMarkdownH5Bg.bg = headerBg;
        RenderMarkdownH6Bg.bg = headerBg;
        RenderMarkdownH1Bg.fg = headerFg;
        RenderMarkdownH2Bg.fg = headerFg;
        RenderMarkdownH3Bg.fg = headerFg;
        RenderMarkdownH4Bg.fg = headerFg;
        RenderMarkdownH5Bg.fg = headerFg;
        RenderMarkdownH6Bg.fg = headerFg;
      };
  };
}
