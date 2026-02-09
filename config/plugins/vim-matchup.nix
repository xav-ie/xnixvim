{ pkgs, ... }:
{
  # even better %
  # https://github.com/andymass/vim-matchup
  # https://nix-community.github.io/nixvim/plugins/vim-matchup
  #
  # The nixvim module doesn't support lazyLoad, so we bypass it:
  # - Add plugin as optional (opt/) via extraPlugins
  # - Load via lz.n on BufReadPost
  # - Treesitter already configures matchup in its after function
  config = {
    extraPlugins = [
      {
        plugin = pkgs.vimPlugins.vim-matchup;
        optional = true;
      }
    ];
    plugins.lz-n.plugins = [
      {
        "__unkeyed-1" = "vim-matchup";
        event = [ "BufReadPost" ];
      }
    ];
    # Keep treesitter matchup integration
    plugins.treesitter.settings.matchup = {
      enable = true;
      include_match_words = true;
    };
  };
}
