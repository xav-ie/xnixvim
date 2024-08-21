{ pkgs, ... }:
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
    # ./neogit.nix
    ./noice.nix
    ./notify.nix
    # ./nvim-lightbulb.nix
    ./oatmeal.nix
    # ./octo-nvim.nix
    ./oil-git-status.nix
    ./oil.nix
    ./ollama.nix
    ./orgmode.nix
    ./org-roam-nvim.nix
    ./sort-group.nix
    ./supermaven.nix
    ./tabscope.nix
    ./telescope
    ./treesitter.nix
    # ./vim-advanced-sorters.nix
    ./vim-matchup.nix
    ./which-key
    # ./zellij.nix
  ];

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
    surround.enable = true;

    todo-comments.enable = true;

    # diagnostics buffer
    trouble.enable = true;
  };

  extraPlugins = with pkgs.vimPlugins; [
    # TODO: configure
    rhubarb # allows easily opening things in github
    vim-unimpaired # better [] jumps
  ];
}
