{ pkgs, helpers, ... }:
{
  imports = [
    ./bufferline.nix
    ./cmp.nix
    ./coq
    ./conform-nvim.nix
    ./flash.nix
    ./gitsigns.nix
    ./lsp
    ./lspkind.nix
    ./lsp-lines.nix
    ./lualine.nix
    ./luasnip.nix
    ./markdown-table-sorter.nix
    ./noice.nix
    ./notify.nix
    # ./nvim-lightbulb.nix
    ./oatmeal.nix
    # ./octo-nvim.nix
    ./oil-git-status.nix
    ./oil.nix
    ./ollama.nix
    ./orgmode.nix
    # ./org-roam-nvim.nix # buggy as hell
    ./tabscope.nix
    ./telescope
    ./treesitter.nix
    ./vim-matchup.nix
    ./which-key
    ./witt-neovim.nix
    # ./zellij.nix
  ] ++ (if helpers.enableExceptInTests then [ ./supermaven.nix ] else [ ]);

  config = {
    plugins = {
      # smart comment/un-comment
      comment.enable = true;

      # automatic env updates
      direnv.enable = true;

      # amazing snippets for every language
      friendly-snippets.enable = true;

      # unstoppable git plugin
      fugitive.enable = true;

      # luasnip expansions in cmp
      cmp_luasnip.enable = true;

      # TODO: figure out if this is possible with just TreeSitter?
      # nix.enable = true;

      # ()[]{}...
      nvim-autopairs.enable = true;

      # colors in Neovim
      nvim-colorizer.enable = true;

      # better folding UI
      # nvim-ufo.enable = true;

      # tpope === goat
      vim-surround.enable = true;

      # todo comment highlighting
      todo-comments.enable = true;

      # diagnostics buffer
      trouble.enable = true;

      # icons 🍥
      web-devicons.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      # TODO: configure
      rhubarb # allows easily opening things in github
      vim-unimpaired # better [] jumps
    ];
  };
}
