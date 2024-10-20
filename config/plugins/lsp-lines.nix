{ ... }:
{
  # better diagnostics UI
  # https://git.sr.ht/~whynothugo/lsp_lines.nvim
  # https://nix-community.github.io/nixvim/plugins/lsp-lines/index.html
  config = {
    plugins.lsp-lines = {
      enable = true;
      # currentLine = true;
    };
  };
}
