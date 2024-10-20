{ ... }:
{
  # VSCode lightbulbs
  # https://github.com/kosayoda/nvim-lightbulb/
  # https://nix-community.github.io/nixvim/plugins/nvim-lightbulb/index.html
  config = {
    # TODO: figure out if this is good or not
    plugins.nvim-lightbulb = {
      enable = true;
      autocmd.enabled = true;
    };
  };
}
