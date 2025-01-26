_: {
  # better diagnostics UI
  # https://git.sr.ht/~whynothugo/lsp_lines.nvim
  # https://nix-community.github.io/nixvim/plugins/lsp-lines
  config = {
    plugins.lsp-lines = {
      enable = true;
      lazyLoad.settings.event = "BufEnter";
      # currentLine = true;
    };
  };
}
