_:
{
  # vscode-like pictograms for neovim lsp completion items
  # https://github.com/onsails/lspkind.nvim
  # https://nix-community.github.io/nixvim/plugins/lspkind
  config = {
    # completion icons
    plugins.lspkind = {
      enable = true;
      cmp = {
        enable = true;
      };
    };
  };
}
