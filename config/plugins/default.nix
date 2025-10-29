{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./bufferline.nix
    ./cmp.nix
    # ./coq
    ./conform-nvim.nix
    ./flash.nix

    # ./firenvim.nix
    ./fugitive.nix
    ./gitsigns.nix
    ./lsp
    ./lazydev.nix
    ./lspkind.nix
    ./lsp-lines.nix
    # TODO: optimize
    # adds 50ms to startup!
    ./lualine.nix
    ./luasnip.nix
    ./markdown-table-sorter.nix
    ./minuet-ai-nvim.nix
    ./noice.nix
    ./notify.nix
    ./nvim-colorizer.nix
    # ./nvim-lightbulb.nix
    ./nvim-scrollview.nix
    # ./oatmeal.nix
    # ./octo-nvim.nix
    ./oil-git-status.nix
    ./oil.nix
    # ./ollama.nix
    # ./orgmode.nix
    # ./org-roam-nvim.nix # buggy as hell
    # ./pretty-ts-errors-nvim.nix
    ./render-markdown.nix
    ./tabscope.nix
    ./telescope
    ./treesitter.nix
    # TODO: fix
    # ./vim-guise.nix
    ./vim-matchup.nix
    ./which-key
    ./witt-neovim.nix
  ];
  # ] ++ (if helpers.enableExceptInTests then [ ./supermaven.nix ] else [ ]);

  # Global lazyLoad on/off
  options.lazyLoad.enable = lib.mkEnableOption "lazyLoad";
  # currently, makes negligible difference in start-up time with the byte
  # compilation on. It even worsens start-up with byte compilation off.
  config.lazyLoad.enable = false;

  config = {
    plugins = {
      lz-n.enable = config.lazyLoad.enable;

      # smart comment/un-comment
      # https://github.com/numtostr/comment.nvim/
      # https://nix-community.github.io/nixvim/plugins/comment
      comment.enable = true;

      # luasnip expansions in cmp
      # https://github.com/saadparwaiz1/cmp_luasnip/
      # https://nix-community.github.io/nixvim/plugins/cmp_luasnip
      cmp_luasnip.enable = true;

      # automatic env updates
      # https://github.com/direnv/direnv.vim/
      # https://nix-community.github.io/nixvim/plugins/direnv
      direnv.enable = true;

      # amazing snippets for every language
      # https://github.com/rafamadriz/friendly-snippets
      # https://nix-community.github.io/nixvim/plugins/friendly-snippets
      friendly-snippets.enable = true;

      # adds syntax highlighting and special helpers for nix files
      # https://github.com/LnL7/vim-nix/
      # https://nix-community.github.io/nixvim/plugins/nix
      # nix.enable = true;
      # TODO: test

      # ()[]{}...
      # https://github.com/windwp/nvim-autopairs/
      # https://nix-community.github.io/nixvim/plugins/nvim-autopairs
      nvim-autopairs.enable = true;

      # better folding UI
      # https://github.com/kevinhwang91/nvim-ufo/
      # https://nix-community.github.io/nixvim/plugins/nvim-ufo
      # nvim-ufo.enable = true;

      # tpope === goat
      # add native-like vim surround command
      # https://github.com/tpope/vim-surround/
      # https://nix-community.github.io/nixvim/plugins/vim-surround
      vim-surround.enable = true;

      # https://gitlab.com/HiPhish/rainbow-delimiters.nvim
      # https://nix-community.github.io/nixvim/plugins/rainbow-delimiters
      rainbow-delimiters.enable = true;

      # todo comment highlighting
      # https://github.com/folke/todo-comments.nvim/
      # https://nix-community.github.io/nixvim/plugins/todo-comments
      todo-comments.enable = true;

      tmux-navigator.enable = true;

      # diagnostics buffer
      # https://github.com/folke/trouble.nvim/
      # https://nix-community.github.io/nixvim/plugins/trouble
      trouble.enable = true;

      # https://github.com/windwp/nvim-ts-autotag/
      # https://nix-community.github.io/nixvim/plugins/ts-autotag
      ts-autotag = {
        enable = true;
        settings.aliases.liquid = "html";
      };

      # icons 🍥
      # https://github.com/nvim-tree/nvim-web-devicons/
      # https://nix-community.github.io/nixvim/plugins/web-devicons
      web-devicons.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      rhubarb # allows easily opening things in github
      vim-unimpaired # better [] jumps
      vim-smoothie # smooth scrolling
    ];
  };
}
