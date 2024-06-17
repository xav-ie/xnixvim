{ ... }:
{
  imports = [
    ./bufferline.nix
    ./cmp.nix
    ./conform-nvim.nix
    ./gitsigns.nix
    ./lsp
    ./lsp-lines.nix
    ./lspkind.nix
    ./luasnip.nix
    ./lualine.nix
    ./markdown-table-sorter.nix
    # ./nvim-lightbulb.nix
    ./noice.nix
    ./ollama.nix
    ./oatmeal.nix
    # ./octo-nvim.nix
    ./oil-git-status.nix
    ./oil.nix
    ./orgmode.nix
    ./org-roam-nvim.nix
    ./telescope.nix
    ./treesitter.nix
    ./vim-matchup.nix
    # ./zellij.nix
  ];

  plugins = {
    # TODO: replace with local version
    # free auto-complete at last
    codeium-nvim.enable = true;

    # smart comment/un-comment
    comment.enable = true;

    # the best git plugin
    fugitive.enable = true;

    # amazing snippets for every language
    friendly-snippets.enable = true;

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
    surround.enable = true;

    todo-comments.enable = true;

    # diagnostics buffer
    trouble.enable = true;

    # TODO: see https://github.com/Alexnortung/nollevim/blob/fcc35456c567c6108774e839d617c97832217e67/config/which-key.nix#L4
    which-key.enable = true;
  };
}
