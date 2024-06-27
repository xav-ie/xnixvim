{ pkgs, ... }:
{
  imports = [
    ./bufferline.nix
    ./cmp.nix
    ./conform-nvim.nix
    ./flash.nix
    ./gitsigns.nix
    ./lsp
    ./lspkind.nix
    ./lsp-lines.nix
    ./lualine.nix
    ./luasnip.nix
    ./markdown-table-sorter.nix
    # ./neogit.nix
    ./noice.nix
    # ./nvim-lightbulb.nix
    ./oatmeal.nix
    # ./octo-nvim.nix
    ./oil-git-status.nix
    ./oil.nix
    ./ollama.nix
    ./orgmode.nix
    ./org-roam-nvim.nix
    ./tabscope.nix
    ./telescope
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
    surround.enable = true;

    todo-comments.enable = true;

    # diagnostics buffer
    trouble.enable = true;

    # TODO: see https://github.com/Alexnortung/nollevim/blob/fcc35456c567c6108774e839d617c97832217e67/config/which-key.nix#L4
    which-key.enable = true;
  };

  extraPlugins = with pkgs.vimPlugins; [
    # TODO: configure
    rhubarb # allows easily opening things in github
    vim-unimpaired # better [] jumps
  ];
}
