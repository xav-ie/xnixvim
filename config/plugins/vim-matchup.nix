{ ... }:
{
  # even better %
  plugins.vim-matchup = {
    treesitterIntegration = {
      enable = true;
      includeMatchWords = true;
    };
    enable = true;
  };
}
