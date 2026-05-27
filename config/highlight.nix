_: {
  config = {
    # All custom highlights were extracted into the xdusk colorscheme
    # (custom-plugins/xdusk). Edit the theme's palette.lua / init.lua to change
    # colors rather than re-adding overrides here.

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
