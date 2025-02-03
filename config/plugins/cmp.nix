{ config, ... }:
{
  # imports = [
  #   ./cmp-luasnip-choice.nix
  # ];

  config = {
    # completions
    # https://github.com/hrsh7th/nvim-cmp
    # https://nix-community.github.io/nixvim/plugins/cmp
    plugins.cmp = {
      enable = true;
      lazyLoad.settings.event = "InsertEnter";
      lazyLoad.enable = config.lazyLoad.enable;
      # only works when sources is not set with __raw
      autoEnableSources = true;
      settings = {
        sources = [
          # TODO: how to dynamically add sources?
          { name = "nvim_lsp"; }
          { name = "minuet"; }
          # { name = "codeium"; }
          { name = "luasnip"; }
          # TODO: only add iff cmp-luasnip-choice enabled
          # { name = "luasnip_choice"; }
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
        # wait 250ms before trying to reach out to minuet
        performance.fetching_timeout = 50;
        mapping = {
          "<A-y>" = "require('minuet').make_cmp_map()";
          "<C-u>" = "cmp.mapping.scroll_docs(-3)";
          "<C-d>" = "cmp.mapping.scroll_docs(3)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<tab>" = "cmp.mapping.close()";
          # TODO: <c-n> and <c-p> seem to be overloaded and
          # do not always do the right thing

          # "<c-n>" = "cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert })";
          # "<c-p>" = "cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert })";
          "<c-n>" = "cmp.mapping.select_next_item({})";
          "<c-.>" = "cmp.mapping.select_next_item({})";
          "<c-p>" = "cmp.mapping.select_prev_item({})";
          "<c-,>" = "cmp.mapping.select_prev_item({})";
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
    highlight = {
      CmpItemAbbrDeprecated = {
        fg = "#d79921";
        bg = "NONE";
        strikethrough = true;
      };
      CmpItemAbbrMatch = {
        fg = "#83a598";
        bg = "NONE";
        bold = true;
      };
      CmpItemAbbrMatchFuzzy = {
        fg = "#83a598";
        bg = "NONE";
        bold = true;
      };
      CmpItemMenu = {
        fg = "#b16286";
        bg = "NONE";
        italic = true;
      };
      CmpItemKindField = {
        fg = "#fbf1c7";
        bg = "#fb4934";
      };
      CmpItemKindProperty = {
        fg = "#fbf1c7";
        bg = "#fb4934";
      };
      CmpItemKindEvent = {
        fg = "#fbf1c7";
        bg = "#fb4934";
      };
      CmpItemKindText = {
        fg = "#fbf1c7";
        bg = "#b8bb26";
      };
      CmpItemKindEnum = {
        fg = "#fbf1c7";
        bg = "#b8bb26";
      };
      CmpItemKindKeyword = {
        fg = "#fbf1c7";
        bg = "#b8bb26";
      };
      CmpItemKindConstant = {
        fg = "#fbf1c7";
        bg = "#fe8019";
      };
      CmpItemKindConstructor = {
        fg = "#fbf1c7";
        bg = "#fe8019";
      };
      CmpItemKindReference = {
        fg = "#fbf1c7";
        bg = "#fe8019";
      };
      CmpItemKindFunction = {
        fg = "#fbf1c7";
        bg = "#b16286";
      };
      CmpItemKindStruct = {
        fg = "#fbf1c7";
        bg = "#b16286";
      };
      CmpItemKindClass = {
        fg = "#fbf1c7";
        bg = "#b16286";
      };
      CmpItemKindModule = {
        fg = "#fbf1c7";
        bg = "#b16286";
      };
      CmpItemKindOperator = {
        fg = "#fbf1c7";
        bg = "#b16286";
      };
      CmpItemKindVariable = {
        fg = "#fbf1c7";
        bg = "#458588";
      };
      CmpItemKindFile = {
        fg = "#fbf1c7";
        bg = "#458588";
      };
      CmpItemKindUnit = {
        fg = "#fbf1c7";
        bg = "#d79921";
      };
      CmpItemKindSnippet = {
        fg = "#fbf1c7";
        bg = "#d79921";
      };
      CmpItemKindFolder = {
        fg = "#fbf1c7";
        bg = "#d79921";
      };

      CmpItemKindMethod = {
        fg = "#fbf1c7";
        bg = "#8ec07c";
      };
      CmpItemKindValue = {
        fg = "#fbf1c7";
        bg = "#8ec07c";
      };
      CmpItemKindEnumMember = {
        fg = "#fbf1c7";
        bg = "#8ec07c";
      };
      CmpItemKindInterface = {
        fg = "#fbf1c7";
        bg = "#83a598";
      };
      CmpItemKindColor = {
        fg = "#fbf1c7";
        bg = "#83a598";
      };
      CmpItemKindTypeParameter = {
        fg = "#fbf1c7";
        bg = "#83a598";
      };
    };

  };
}
