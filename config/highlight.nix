_: {
  config = {
    highlight = {
      # Fix code background
      ColorColumn.bg = "#200020";
      # ColorColumn.underline = true;
      DiffChange.fg = "#ffb20f";
      DiffDelete.fg = "#ff0000";
      FloatBorder.fg = "#a89984";
      Pmenu.bg = "#282828";
      Pmenu.fg = "#ebdbb2";
      PmenuSel.bg = "#504945";
      PmenuSel.fg = "NONE";
      # tab bar background
      TabLineFill.bg = "NONE";
      TermCursor.underdotted = true;
      TermCursor.sp = "#ffb20f";
      GitSignsAddInline.underdotted = true;
      GitSignsAddInline.sp = "#00ff00";
      GitSignsDeleteInline.underdotted = true;
      GitSignsDeleteInline.sp = "#ff0000";
      GitSignsDeleteInline.fg = "#ff4400";
      TSLiteral.bg = "#200020";
      TSLiteral.fg = "#00a0f0";
      TSNumber.fg = "#be620a";
      TSProperty.fg = "#FFD242";
      TSType.fg = "#00a0f0";
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
