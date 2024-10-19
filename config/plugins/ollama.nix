{ ... }:
{
  config = {
    plugins.ollama = {
      enable = true;
      model = "codellama";
    };
  };
}
