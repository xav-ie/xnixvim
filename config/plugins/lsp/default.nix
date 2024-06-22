{ ... }:
{
  imports = [ ./SchemaStore-nvim.nix ];

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

      lspBuf = {
        K = "hover";
      };

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
      ];
    };
    servers = {
      eslint.enable = true;
      gopls.enable = true;
      graphql.enable = true;
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
      lua-ls.enable = true;
      nil_ls = {
        enable = true;
        settings.formatting.command = [ "nixfmt-rfc-style" ];
      };
      rust-analyzer = {
        enable = true;
        installCargo = true;
        installRustc = true;
      };
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
      tsserver = {
        enable = true;
        onAttach.function = # lua
          ''
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(true)
            end
          '';
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
}
