{ pkgs, inputs, ... }:
let
  SchemaStore-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "SchemaStore.nvim";
    src = inputs.schemastore-nvim;
  };
in
{
  # JSON schemas for Neovim
  # https://github.com/b0o/SchemaStore.nvim
  config = {
    extraPlugins = [ SchemaStore-nvim ];

    # Defer schemastore catalog loading until a JSON file is actually opened
    extraConfigLua = # lua
      ''
        vim.api.nvim_create_autocmd("FileType", {
          pattern = { "json", "jsonc" },
          once = true,
          callback = function()
            vim.lsp.config("jsonls", {
              settings = {
                json = {
                  schemas = require('schemastore').json.schemas {
                    replace = {
                      ['A micro editor config'] = {
                        description = "A micro editor config",
                        fileMatch = { "settings.json" },
                        name = "A micro editor config",
                        url = "https://json.schemastore.org/micro.json"
                      },
                    },
                  },
                },
              },
            })
          end,
        })
      '';
  };
}
