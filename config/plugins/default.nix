{ ... }:
{
  imports = [
    ./bufferline.nix
    ./cmp.nix
    ./conform-nvim.nix
    ./gitsigns.nix
    ./lsp
    ./lualine.nix
    ./noice.nix
    ./oil.nix
    ./telescope.nix
    ./treesitter.nix
  ];

  plugins = {

    # free auto-complete at least
    # TODO: replace with local version
    codeium-nvim = {
      enable = true;
    };

    # smart comment/un-comment
    comment.enable = true;

    flash = {
      enable = true;
      # auto-jump when there is only one match
      jump.autojump = true;
    };

    # the best git plugin
    fugitive.enable = true;

    # amazing snippets for every language
    friendly-snippets.enable = true;

    # completion icons
    lspkind = {
      enable = true;
      cmp = {
        enable = true;
      };
    };

    # better diagnostics UI
    lsp-lines = {
      enable = true;
      # currentLine = true;
    };

    # useful code expansions
    luasnip = {
      enable = true;
      extraConfig = {
        #   enable_autosnippets = true;
        #   store_selection_keys = “<Tab>”;
      };
      fromVscode = [ { } ];
    };

    # luasnip expansions in cmp
    cmp_luasnip.enable = true;

    # TODO: figure out if this is possible with just TreeSitter?
    # nix.enable = true;

    ollama = {
      enable = true;
      model = "codellama";
    };

    # ()[]{}...
    nvim-autopairs.enable = true;

    # colors in Neovim
    nvim-colorizer.enable = true;

    # TODO: figure out if this is good or not
    # VSCode lightbulbs
    # nvim-lightbulb = {
    #   enable = true;
    #   autocmd.enabled = true;
    # };

    # better folding UI
    # nvim-ufo.enable = true;

    # tpope === goat
    surround.enable = true;

    todo-comments.enable = true;

    # diagnostics buffer
    trouble.enable = true;

    # even better %
    vim-matchup = {
      treesitterIntegration = {
        enable = true;
        includeMatchWords = true;
      };
      enable = true;
    };

    # TODO: see https://github.com/Alexnortung/nollevim/blob/fcc35456c567c6108774e839d617c97832217e67/config/which-key.nix#L4
    which-key.enable = true;

    # zellij = {
    #   enable = true;
    #
    #   settings = {
    #     debug = true;
    #     vimTmuxNavigatorKeybinds = true;
    #     whichKeyEnabled = true;
    #     replaceVimWindowNavigationKeybinds = true;
    #   };
    # };
  };
}
