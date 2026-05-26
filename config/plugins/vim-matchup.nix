{ pkgs, ... }:
{
  # even better %
  # https://github.com/andymass/vim-matchup
  # https://nix-community.github.io/nixvim/plugins/vim-matchup
  #
  # The nixvim module doesn't support lazyLoad, so we bypass it:
  # - Add plugin as optional (opt/) via extraPlugins
  # - Load via lz.n on BufReadPost
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
        event = [
          "BufReadPost"
          "BufNewFile"
        ];
      }
    ];
    # NOTE: nvim-treesitter's `main` branch dropped the configs module, so the
    # old `plugins.treesitter.settings.matchup` integration is a no-op and was
    # removed. vim-matchup's regex-based `%` matching is unaffected.
  };
}
