{
  pkgs,
  inputs,
  system,
  ...
}:
let
  rocq-lsp = inputs.vscoq.packages.${system}.default;
in
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
      # Youch! Detaching LSP is annoying and there is no such should_attach method :/
      # https://github.com/neovim/nvim-lspconfig/issues/2626#issuecomment-2117022664
      # https://github.com/neovim/nvim-lspconfig/issues/2508#issuecomment-1966885690
      luaConfig.pre = ''
        local bufIsBig = function(bufnr)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
          return ok and stats and stats.size > max_filesize
        end

        -- Track manually started buffers
        local manual_buffers = {}

        -- Create command to force LSP on large files
        vim.api.nvim_create_user_command("LspStartForce", function()
          local bufnr = vim.api.nvim_get_current_buf()
          manual_buffers[bufnr] = true
          -- Re-trigger LSP setup for this buffer
          vim.cmd("edit!")
        end, {})

        -- Override LSP attachment behavior because default lsp attachment
        -- behavior is bad and annoying to configure, see above links
        local original_start = vim.lsp.start
        vim.lsp.start = function(config, opts)
          opts = opts or {}
          local bufnr = opts.bufnr or 0

          -- Check if buffer is too big and not manually allowed
          if bufIsBig(bufnr) and not manual_buffers[bufnr] then
            local server_name = config.name or "LSP server"

            -- Initialize counter for new buffers
            if not vim.b[bufnr].lsp_block_counter then
              vim.b[bufnr].lsp_block_counter = 0
            end

            vim.schedule(function()
              local delay = vim.b[bufnr].lsp_block_counter * 700
              vim.b[bufnr].lsp_block_counter = vim.b[bufnr].lsp_block_counter + 1

              vim.defer_fn(function()
                vim.api.nvim_echo({
                  {"Buffer too large for ", "Normal"},
                  {server_name, "Function"},
                  {". Use ", "Normal"},
                  {":LspStartForce", "Special"},
                  {" to override.", "Normal"},
                }, true, {})
              end, delay)
            end)
            return
          end

          return original_start(config, opts)
        end

        -- Clean up when buffer is deleted
        vim.api.nvim_create_autocmd("BufDelete", {
          callback = function(t)
            manual_buffers[t.buf] = nil
          end
        })
      '';

      # TODO: Is this good idea?
      # lazyLoad.settings.event = "BufEnter";
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
        # https://github.com/arduino/arduino-language-server
        arduino_language_server.enable = true;
        # https://github.com/withastro/language-tools
        astro.enable = true;
        # https://github.com/ejgallego/coq-lsp
        coq_lsp = {
          enable = true;
          package = rocq-lsp;
        };
        # https://docs.deno.com/runtime/reference/lsp_integration/
        denols = {
          # makes to many network requests when it should not
          enable = false;
          rootMarkers = [
            "deno.json"
            "deno.jsonc"
          ];
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
        # Must specify our own package:
        # https://github.com/nix-community/nixvim/commit/e8025891b24036bcc76fd355a5edec9fbf2e359b
        # https://github.com/NixOS/nixpkgs/pull/382557
        # https://github.com/NixOS/nixpkgs/pull/384397
        graphql = {
          enable = true;
          package = pkgs.graphql-language-service-cli;
        };
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
        };
        # https://github.com/oxalica/nil
        nil_ls = {
          enable = true;
          settings.formatting.command = [ "nixfmt-rfc-style" ];
        };
        ruff = {
          enable = true;
        };
        # https://rust-analyzer.github.io/
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
          settings = {
            # cfg = {
            #   mobile = "";
            # };
            # cargo = {
            #   # allFeatures = true;
            #   # features = "all";
            #   # cfgs.mobile = "";
            #   cfgs.mobile = null;
            # };
            # diagnostics = {
            #   disabled = [ "inactive-code" ];
            # };
          };
        };
        # https://nix-community.github.io/nixvim/plugins/lsp/servers/shopify_theme_ls
        shopify_theme_ls = {
          enable = true;
          filetypes = [ "liquid" ];
          # TODO: checkout
          # https://github.com/tlegasse/kickstart.nvim/blob/d30ee6e30be0e82ece0f18164a91adb02356ef5f/lua/lsp-config.lua#L7
          # and improve this awful code
          rootMarkers = [
            ".theme-check.yml"
            "templates"
            "sections"
            ".git"
          ];
        };

        # https://nix-community.github.io/nixvim/plugins/lsp/servers/sourcekit
        sourcekit.enable = true;
        # You need to do this for every svelte project
        # `npm install --save-dev typescript-svelte-plugin`
        # Ajust tsconfig.json to include the plugin:
        # ```tsconfig.json
        # {
        #   "compilerOptions": {
        #       ...
        #       "plugins": [{
        #           "name": "typescript-svelte-plugin",
        #           "enabled": true,
        #           "assumeIsSvelteProject": false
        #       }]
        #   }
        # }
        # ```
        # https://github.com/sveltejs/language-tools/tree/master/packages/typescript-plugin#usage
        svelte = {
          enable = true;

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
          #     vim.print(client.config.init_options)
          #   '';
          extraOptions = {
            single_file_support = false;
            # Adds basic support for reading .vscode/settings.json. Does not account for project root.
            # Should add project root support eventually or make separate `init_options` parser plugin
            init_options.preferences.__raw = # lua
              ''
                (function()
                    local settings_path = vim.fs.find('.vscode/settings.json', { upward = true })[1]
                    if not settings_path then return nil end
                    local file = io.open(settings_path, 'r')
                    if not file then return nil end

                    local content = file:read('*a')
                    file:close()

                    local ok, settings = pcall(vim.json.decode, content)
                    if not ok then
                        vim.notify('Failed to parse .vscode/settings.json: ' .. (settings or 'unknown error'), vim.log.levels.WARN)
                        return nil
                    end
                    if not settings then return nil end

                    -- Recursively build nested tables from dotted keys
                    local function build_nested(tbl)
                      local result = {}
                      for key, value in pairs(tbl) do
                        local parts = {}
                        for part in key:gmatch('[^.]+') do
                          table.insert(parts, part)
                        end

                        local current = result
                        for i = 1, #parts - 1 do
                          local part = parts[i]
                          if not current[part] then
                            current[part] = {}
                          end
                          current = current[part]
                        end

                        current[parts[#parts]] = value
                      end
                      return result
                    end

                    -- Transform the settings object
                    local nested_settings = build_nested(settings)

                    -- Extract the importModuleSpecifier preference
                    if nested_settings.typescript and nested_settings.typescript.preferences then
                      local preferences = nested_settings.typescript.preferences
                      -- .vscode/settings json has proprietary config format
                      -- that is not 100% LSP 1:1 compatible. So we must perform some
                      -- transformations on the preferences to proper LSP settings
                      -- https://github.com/microsoft/vscode/blob/da1f16ceaced7682eac0b6c8e3dac4dd0f8575a1/extensions/typescript-language-features/src/languageFeatures/fileConfigurationManager.ts#L187

                      -- rename "importModuleSpecifier" to "importModuleSpecifierPreference"
                      if preferences.importModuleSpecifier then
                          preferences.importModuleSpecifierPreference = preferences.importModuleSpecifier
                          preferences.importModuleSpecifier = nil
                      end


                      return preferences
                    end

                    return nil
                end)()
              '';
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
            rootMarkers = [ "package.json" ];
          };
        };
        zls = {
          enable = true;
        };
      };
    };
  };
}
