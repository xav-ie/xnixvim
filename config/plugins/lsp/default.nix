{ helpers, pkgs, ... }:
{
  imports = [ ./SchemaStore-nvim.nix ];

  # LSP
  # https://github.com/neovim/nvim-lspconfig
  # https://nix-community.github.io/nixvim/plugins/lsp
  config = {
    extraConfigLua =
      # lua
      ''
        -- add border to diagnostic windows
        vim.diagnostic.config {
          float = { border = "single" },
        }
      '';

    plugins.lsp = {
      enable = true;
      keymaps = {
        silent = true;
        diagnostic = {
          # Navigate in diagnostics
          "[d" = "goto_prev";
          "]d" = "goto_next";
        };

        # TODO: make more strict like in ../../keymaps.nix
        extra = [
          {
            key = "<leader>la";
            options.desc = "LSP Code [a]ctions";
            action.__raw = # lua
              ''function() vim.lsp.buf.code_action() end'';
          }
          {
            key = "<leader>lc";
            options.desc = "LSP Incoming [c]alls";
            action = "<cmd>Telescope lsp_incoming_calls<CR>";
          }
          {
            key = "<leader>lC";
            options.desc = "LSP Outgoing [C]alls";
            action = "<cmd>Telescope lsp_outgoing_calls<CR>";
          }
          {
            key = "<leader>ld";
            options.desc = "LSP [d]efinition";
            action = "<cmd>Telescope lsp_definitions<CR>";
          }
          {
            key = "<leader>lf";
            options.desc = "LSP [f]ormatting";
            action.__raw = # lua
              ''function() vim.lsp.buf.format { async = true } end'';
          }
          {
            key = "<leader>lg";
            options.desc = "LSP Dia[g]nostics";
            action.__raw = # lua
              ''function() vim.lsp.diagnostic.open_float() end'';
          }
          {
            key = "<leader>lh";
            options.desc = "LSP Toggle Inlay [h]ints";
            action.__raw = # lua
              ''function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end'';
          }
          {
            key = "<leader>li";
            options.desc = "LSP [i]mplementations";
            action = "<cmd>Telescope lsp_implementations<CR>";
          }
          {
            key = "<leader>lo";
            options.desc = "LSP D[o]cument Symbols";
            action = "<cmd>Telescope lsp_document_symbols<CR>";
          }
          {
            key = "<leader>ln";
            options.desc = "LSP Re[n]ame";
            action.__raw = # lua
              ''function() vim.lsp.buf.rename() end'';
          }
          {
            key = "<leader>lr";
            options.desc = "LSP [r]eferences";
            action = "<cmd>Telescope lsp_references<CR>";
          }
          {
            key = "<leader>lt";
            options.desc = "LSP [t]ype Definitions";
            action = "<cmd>Telescope lsp_type_definitions<CR>";
          }
          {
            key = "<leader>lw";
            options.desc = "LSP [w]orkspace Symbols";
            action = "<cmd>Telescope lsp_workspace_symbols<CR>";
          }
          {
            key = "<leader>ly";
            options.desc = "LSP D[y]namic Symbols";
            action = "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>";
          }

          # Global maps
          {
            key = "K";
            options.desc = "LSP Hover";
            action.__raw = # lua
              ''function() vim.lsp.buf.hover() end'';
          }
          {
            key = "<leader>th";
            options.desc = "LSP Toggle Inlay [h]ints";
            action.__raw = # lua
              ''function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end'';
          }
        ];
      };
      # all servers come from:
      # https://github.com/nix-community/nixvim/blob/c4ad4d0b2e7de04fa9ae0652b006807f42062080/plugins/lsp/lsp-packages.nix#L179
      servers = {
        # https://github.com/withastro/language-tools
        astro.enable = true;
        # https://github.com/ejgallego/coq-lsp
        coq_lsp = {
          enable = true;
          # not sure what the right default is?
          package = pkgs.coqPackages.coq-lsp;
        };
        # https://docs.deno.com/runtime/reference/lsp_integration/
        denols = {
          enable = true;
          rootDir = # lua
            ''
              require('lspconfig').util.root_pattern("deno.json", "deno.jsonc")
            '';
          extraOptions.init_options = {
            lint = true;
            unstable = true;
          };
        };
        # https://github.com/hrsh7th/vscode-langservers-extracted
        eslint.enable = true;
        # https://github.com/nolanderc/glsl_analyzer
        glsl_analyzer.enable = true;
        # https://github.com/golang/tools/tree/master/gopls
        gopls.enable = true;
        # https://github.com/graphql/graphiql/tree/main/packages/graphql-language-service-cli#readme
        graphql.enable = true;
        # https://github.com/hrsh7th/vscode-langservers-extracted
        jsonls = {
          enable = true;
          extraOptions.settings.json = {
            schemas.__raw = # lua
              ''
                require('schemastore').json.schemas {
                  replace = {
                    -- Micro editor config is currently too greedy
                    ['A micro editor config'] = {
                      description = "A micro editor config",
                      fileMatch = { "settings.json" },
                      name = "A micro editor config",
                      url = "https://json.schemastore.org/micro.json"
                    },
                  },
                }
              '';
            validate.enable = true;
          };
        };
        # https://github.com/luals/lua-language-server
        lua_ls = {
          enable = true;
          settings = {
            # nixvim adds the "Lua"
            # Lua = {
            # runtime.version = "LuaJIT"; # not sure if needed/desired
            # diagnostics.globals = [ "vim" ]; # should not be needed if types are
            #                                  # sourced correctly
            workspace.library = [
              (helpers.mkRaw # lua
                ''
                  vim.env.VIMRUNTIME,
                  -- ^ just this is enough for me!, keeping the rest just in case
                  -- vim.api.nvim_get_runtime_file("", true),
                  -- [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                  -- [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
                ''
              )
            ];
            # };
          };
        };
        # https://github.com/oxalica/nil
        nil_ls = {
          enable = true;
          settings.formatting.command = [ "nixfmt-rfc-style" ];
        };
        # https://rust-analyzer.github.io/
        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
        };
        # https://github.com/vuejs/vetur/tree/master/server
        # https://nix-community.github.io/nixvim/plugins/lsp/servers/vuels/index.html
        volar = {
          enable = true;
        };
        # https://github.com/typescript-language-server/typescript-language-server
        ts_ls = {
          enable = true;
          # onAttach.function = # lua
          #   ''
          #     if client.server_capabilities.inlayHintProvider then
          #       vim.lsp.inlay_hint.enable(true)
          #     end
          #   '';
          extraOptions = {
            single_file_support = false;
            settings =
              let
                inlayHints = {
                  includeInlayEnumMemberValueHints = true;
                  includeInlayFunctionLikeReturnTypeHints = true;
                  includeInlayFunctionParameterTypeHints = true;
                  includeInlayParameterNameHints = "all";
                  includeInlayParameterNameHintsWhenArgumentMatchesName = true;
                  includeInlayPropertyDeclarationTypeHints = true;
                  includeInlayVariableTypeHints = true;
                };
              in
              {
                javascript = {
                  inherit inlayHints;
                };
                typescript = {
                  inherit inlayHints;
                };
              };
            commands = {
              OrganizeImports.__raw = # lua
                ''
                  {
                    function()
                      vim.lsp.buf.execute_command {
                        title = "",
                        command = "_typescript.organizeImports",
                        arguments = { vim.api.nvim_buf_get_name(0) },
                      }
                    end,
                    description = "Organize Imports",
                  }
                '';
            };
            rootDir = # lua
              ''
                require('lspconfig').util.root_pattern("package.json")
              '';
          };
        };
      };
    };
  };
}
