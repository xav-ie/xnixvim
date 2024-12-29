_: {
  # Ollama (AI tool) + nvim
  # https://github.com/nomnivore/ollama.nvim
  # https://nix-community.github.io/nixvim/plugins/ollama
  config = {
    plugins.ollama = {
      enable = true;
      model = "codellama";
    };
  };
}
