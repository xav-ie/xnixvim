{ ... }:
{
  # even better %
  # https://github.com/andymass/vim-matchup
  # https://nix-community.github.io/nixvim/plugins/vim-matchup
  config = {
    plugins.vim-matchup = {
      treesitterIntegration = {
        enable = true;
        includeMatchWords = true;
      };
      enable = true;
    };
  };
}
