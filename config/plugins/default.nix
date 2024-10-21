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
    ./nvim-colorizer.nix
    # ./nvim-lightbulb.nix
    ./nvim-scrollview.nix
    ./oatmeal.nix
    # ./octo-nvim.nix
    ./oil-git-status.nix
    ./oil.nix
    ./ollama.nix
    # ./orgmode.nix
    # ./org-roam-nvim.nix # buggy as hell
    ./tabscope.nix
    ./telescope
    ./treesitter.nix
    ./vim-guise.nix
    ./vim-matchup.nix
    ./which-key
    ./witt-neovim.nix
  ] ++ (if helpers.enableExceptInTests then [ ./supermaven.nix ] else [ ]);

  config = {
    plugins = {
      # smart comment/un-comment
      # https://github.com/numtostr/comment.nvim/
      # https://nix-community.github.io/nixvim/plugins/comment/index.html
      comment.enable = true;

      # luasnip expansions in cmp
      # https://github.com/saadparwaiz1/cmp_luasnip/
      # https://nix-community.github.io/nixvim/plugins/cmp_luasnip.html
      cmp_luasnip.enable = true;

      # automatic env updates
      # https://github.com/direnv/direnv.vim/
      # https://nix-community.github.io/nixvim/plugins/direnv/index.html
      direnv.enable = true;

      # amazing snippets for every language
      # https://github.com/rafamadriz/friendly-snippets
      # https://nix-community.github.io/nixvim/plugins/friendly-snippets.html
      friendly-snippets.enable = true;

      # unstoppable git plugin
      # https://github.com/tpope/vim-fugitive/
      # https://nix-community.github.io/nixvim/plugins/fugitive.html
      fugitive.enable = true;

      # adds syntax highlighting and special helpers for nix files
      # https://github.com/LnL7/vim-nix/
      # https://nix-community.github.io/nixvim/plugins/nix.html
      # nix.enable = true;
      # TODO: test

      # ()[]{}...
      # https://github.com/windwp/nvim-autopairs/
      # https://nix-community.github.io/nixvim/plugins/nvim-autopairs/index.html
      nvim-autopairs.enable = true;

      # better folding UI
      # https://github.com/kevinhwang91/nvim-ufo/
      # https://nix-community.github.io/nixvim/plugins/nvim-ufo/index.html
      # nvim-ufo.enable = true;

      # tpope === goat
      # add native-like vim surround command
      # https://github.com/tpope/vim-surround/
      # https://nix-community.github.io/nixvim/plugins/vim-surround.html
      vim-surround.enable = true;

      # todo comment highlighting
      # https://github.com/folke/todo-comments.nvim/
      # https://nix-community.github.io/nixvim/plugins/todo-comments/index.html
      todo-comments.enable = true;

      # diagnostics buffer
      # https://github.com/folke/trouble.nvim/
      # https://nix-community.github.io/nixvim/plugins/trouble/index.html
      trouble.enable = true;

      # icons 🍥
      # https://github.com/nvim-tree/nvim-web-devicons/
      # https://nix-community.github.io/nixvim/plugins/web-devicons/index.html
      web-devicons.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      rhubarb # allows easily opening things in github
      vim-unimpaired # better [] jumps
      vim-smoothie # smooth scrolling
    ];
  };
}
