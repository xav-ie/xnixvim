_: {
  config = {
    highlight = {
      # ColorColumn.underline = true;
      FloatBorder.fg = "#a89984";
      Pmenu.bg = "#282828";
      Pmenu.fg = "#ebdbb2";
      PmenuSel.bg = "#504945";
      PmenuSel.fg = "NONE";
      # Fix code background
      ColorColumn.bg = "#200020";
      # tab bar background
      TabLineFill.bg = "NONE";
      TSNumber.fg = "#be620a";
      TSProperty.fg = "#FFD242";
      TSType.fg = "#00a0f0";
      TSLiteral.fg = "#00a0f0";
      TSLiteral.bg = "#200020";
    };
    # TODO: get this working
    # extraFiles = {
    #   "markdown/injections.scm" = {
    #     text = # scheme
    #       ''
    #         ; extends
    #         (fenced_code_block
    #           (info_string) @injection.language
    #           (code_fence_content) @injection.content
    #         )
    #       '';
    #     target = "after/queries/markdown/injections.scm";
    #   };
    #   "markdown/textobjects.scm" = {
    #     text = # scheme
    #       ''
    #         ; extends
    #         (fenced_code_block) @codeblock.outer
    #         (fenced_code_block (code_fence_content) @codeblock.inner)
    #       '';
    #     target = "after/queries/markdown/textobjects.scm";
    #   };
    # };
  };
}
