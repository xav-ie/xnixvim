{ ... }:
{
  imports = [ ./SchemaStore-nvim.nix ];

  plugins.lsp = {
    enable = true;
    keymaps = {
      silent = true;
      diagnostic = {
        # Navigate in diagnostics
        "[d" = "goto_prev";
        "]d" = "goto_next";
        "<leader>d" = "open_float";
      };

      lspBuf = {
        gd = "definition";
        gD = "references";
        gt = "type_definition";
        gi = "implementation";
        K = "hover";
        "<leader>r" = "rename";
      };
    };
    #onAttach = ''
    #  vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
    #'';
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
