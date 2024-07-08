{ pkgs, ... }:
let
  coq-lsp = pkgs.vimUtils.buildVimPlugin {
    name = "coq-lsp.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "tomtomjhj";
      repo = "coq-lsp.nvim";
      rev = "e8f8edd56bde52e64f98824d0737127356b8bd4e";
      hash = "sha256-hBr0gi1FD3eZa45mUe3ohJ13SVd7v75udPT8ttH9dNE=";
    };
  };
in
{
  # TODO: add specific dep on nix binary

  extraConfigLua = # lua
    ''
      -- vim.g.loaded_coqtail = 1
      -- vim.g.coqtail.supported = 0
      require'coq-lsp'.setup {
        -- The configuration for coq-lsp.nvim.
        -- The following is the default configuration.
        coq_lsp_nvim = {
          -- to be added
        },

        -- The configuration forwarded to `:help lspconfig-setup`.
        -- The following is an example.
        lsp = {
          on_attach = function(client, bufnr)
            -- your mappings, etc
          end,
          -- coq-lsp server initialization configurations, defined here:
          -- https://github.com/ejgallego/coq-lsp/blob/main/editor/code/src/config.ts#L3
          -- Documentations are at https://github.com/ejgallego/coq-lsp/blob/main/editor/code/package.json.
          init_options = {
            show_notices_as_diagnostics = true,
          },
          autostart = false, -- use this if you want to manually launch coq-lsp with :LspStart.
        },
      }
    '';

  extraPlugins = [ coq-lsp ];
}
