{
  config,
  lib,
  pkgs,
  ...
}:
let
  aiProvider = config.programs.ai-completion-provider;

  # Lazy variant of autoEnableSources: adds cmp source plugins as optional
  # (opt/) so they load with cmp on InsertEnter instead of at startup.
  # Uses nixvim's cmpSourcePlugins mapping directly.
  enabledSourceNames = map (s: s.name) config.plugins.cmp.settings.sources;

  # Sources managed separately (e.g. with custom package overrides)
  excludedSources = [ "luasnip" ];

  lazySourcePlugins = lib.filter (p: p != null) (
    map (
      name:
      let
        pluginAttr = config.cmpSourcePlugins.${name} or null;
      in
      if
        pluginAttr != null
        && !(lib.elem name excludedSources)
        && builtins.hasAttr pluginAttr pkgs.vimPlugins
      then
        {
          plugin = pkgs.vimPlugins.${pluginAttr};
          optional = true;
        }
      else
        null
    ) enabledSourceNames
  );
in
{
  # imports = [
  #   ./cmp-luasnip-choice.nix
  # ];

  config = {
    # Stub cmp module early so after/plugin/cmp_*.lua scripts don't error
    # at startup when cmp is lazy-loaded via lz.n. The stub is overwritten
    # when the real cmp loads on InsertEnter.
    # See: https://github.com/hrsh7th/nvim-cmp/issues/2021
    extraConfigLuaPre = lib.mkIf config.lazyLoad.enable ''
      local _cmp_stub = function()
        return setmetatable({}, {
          __index = function() return function() end end
        })
      end
      package.preload['cmp'] = _cmp_stub
      package.preload['cmp_luasnip'] = _cmp_stub
    '';

    # Add cmp source plugins as optional (opt/) so they don't load at startup
    extraPlugins = lib.mkIf config.lazyLoad.enable lazySourcePlugins;

    # Restore cmp-nvim-lsp capabilities (normally set by autoEnableSources)
    # packadd first since the plugin is in opt/ for lazy loading
    plugins.lsp.capabilities = lib.mkIf (lib.elem "nvim_lsp" enabledSourceNames) ''
      vim.cmd.packadd("cmp-nvim-lsp")
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
    '';

    # completions
    # https://github.com/hrsh7th/nvim-cmp
    # https://nix-community.github.io/nixvim/plugins/cmp
    plugins.cmp = {
      enable = true;
      lazyLoad.settings.event = "InsertEnter";
      lazyLoad.enable = config.lazyLoad.enable;
      # Clear the cmp stub before setup so require('cmp') loads the real module
      luaConfig.pre = ''
        package.loaded['cmp'] = nil
        package.preload['cmp'] = nil
      '';
      # lz.n's packadd doesn't source after/plugin scripts post-startup,
      # so we re-source them after cmp loads.
      # See: https://github.com/hrsh7th/nvim-cmp/issues/2021
      luaConfig.post = ''
        -- Clear cached cmp source modules and preload stubs
        for name, _ in pairs(package.loaded) do
          if name:match('^cmp_') then
            package.loaded[name] = nil
          end
        end
        for name, _ in pairs(package.preload) do
          if name:match('^cmp_') then
            package.preload[name] = nil
          end
        end
        vim.cmd("runtime! after/plugin/cmp_*.lua")
      '';
      # Disabled — we manually add sources as optional plugins below
      # so they don't load at startup from start/
      autoEnableSources = false;
      settings = {
        sources = [
          { name = "nvim_lsp"; }
        ]
        ++ lib.optional (aiProvider == "minuet") { name = "minuet"; }
        ++ [
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
          "<C-u>" = "cmp.mapping.scroll_docs(-3)";
          "<C-d>" = "cmp.mapping.scroll_docs(3)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<c-n>" = "cmp.mapping.select_next_item({})";
          "<c-p>" = "cmp.mapping.select_prev_item({})";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
        }
        # Tab is used by cursortab for accepting completions
        // lib.optionalAttrs (aiProvider != "cursortab") {
          "<tab>" = "cmp.mapping.close()";
        }
        // lib.optionalAttrs (aiProvider == "minuet") {
          "<A-y>" = "require('minuet').make_cmp_map()";
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
