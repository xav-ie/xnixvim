_:
{
  # even better %
  # https://github.com/andymass/vim-matchup
  # https://nix-community.github.io/nixvim/plugins/vim-matchup
  config = {
    plugins.vim-matchup = {
      treesitter = {
        enable = true;
        include_match_words = true;
      };
      enable = true;
    };
  };
}
