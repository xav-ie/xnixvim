{ ... }:
{
  # even better %
  # https://nix-community.github.io/nixvim/plugins/vim-matchup/index.html
  # https://github.com/andymass/vim-matchup
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
