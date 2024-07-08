{ ... }:
{
  # completions
  plugins.cmp = {
    enable = true;
    # only works when sources is not set with __raw
    autoEnableSources = true;
    settings = {
      sources = [
        # TODO: how to dynamically add sources?
        { name = "nvim_lsp"; }
        # { name = "codeium"; }
        { name = "luasnip"; }
        { name = "path"; }
        {
          name = "buffer";
          # Words from other open buffers can also be suggested.
          option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
        }
        # IDK what this one is
        # { name = "calc"; }
        # TODO: {name = "neorg";}
      ];
      mapping = {
        "<C-u>" = "cmp.mapping.scroll_docs(-3)";
        "<C-d>" = "cmp.mapping.scroll_docs(3)";
        "<C-Space>" = "cmp.mapping.complete()";
        "<tab>" = "cmp.mapping.close()";
        "<c-n>" = "cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert })";
        "<c-p>" = "cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert })";
        "<CR>" = "cmp.mapping.confirm({ select = true })";
      };
      snippet.expand = # lua
        ''
          function(args)
            require('luasnip').lsp_expand(args.body)
          end
        '';
    };
    # extraOptions.experimental = {
    #   ghost_text = true;
    # };
  };
}
