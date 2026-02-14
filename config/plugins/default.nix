{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./bgwinch.nix
    ./bufferline.nix
    ./cmp.nix
    # ./coq
    ./conform-nvim.nix
    ./direnv.nix
    ./flash.nix

    # ./firenvim.nix
    ./fugitive.nix
    ./git-heat.nix
    ./gitsigns.nix
    ./inc-rename.nix
    ./jjdescription.nix
    ./lsp
    ./lazydev.nix
    ./lspkind.nix
    ./lsp-lines.nix
    ./lualine.nix
    ./luasnip.nix
    ./markdown-table-sorter.nix
    ./completion-providers
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
    # ./supermaven.nix
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
  config.lazyLoad.enable = true;

  # AI completion provider: null (disabled), "minuet", or "cursortab"
  config.programs.ai-completion-provider = "cursortab";

  config = {
    plugins = {
      lz-n.enable = config.lazyLoad.enable;

      # smart comment/un-comment
      # https://github.com/numtostr/comment.nvim/
      # https://nix-community.github.io/nixvim/plugins/comment
      comment = {
        enable = true;
        lazyLoad.enable = config.lazyLoad.enable;
        lazyLoad.settings.event = [
          "BufReadPost"
          "BufNewFile"
        ];
      };

      # luasnip expansions in cmp
      # https://github.com/saadparwaiz1/cmp_luasnip/
      # https://nix-community.github.io/nixvim/plugins/cmp_luasnip
      cmp_luasnip = {
        enable = true;
        # Strip luasnip from Nix dependencies so it stays in opt/ (managed
        # by lz.n) instead of being pulled into start/ where its plugin
        # scripts add ~7ms to startup.
        package = pkgs.vimPlugins.cmp_luasnip.overrideAttrs (_: {
          dependencies = [ ];
        });
      };

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
      nvim-autopairs = {
        enable = true;
        lazyLoad.enable = config.lazyLoad.enable;
        lazyLoad.settings.event = "InsertEnter";
      };

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
      todo-comments = {
        enable = true;
        lazyLoad.enable = config.lazyLoad.enable;
        lazyLoad.settings.event = [
          "BufReadPost"
          "BufNewFile"
        ];
      };

      tmux-navigator.enable = true;

      # diagnostics buffer
      # https://github.com/folke/trouble.nvim/
      # https://nix-community.github.io/nixvim/plugins/trouble
      trouble = {
        enable = true;
        lazyLoad.enable = config.lazyLoad.enable;
        lazyLoad.settings.cmd = "Trouble";
      };

      # https://github.com/windwp/nvim-ts-autotag/
      # https://nix-community.github.io/nixvim/plugins/ts-autotag
      ts-autotag = {
        enable = true;
        lazyLoad.enable = config.lazyLoad.enable;
        lazyLoad.settings.event = [
          "BufReadPost"
          "BufNewFile"
        ];
        settings.aliases.liquid = "html";
      };

      # icons 🍥
      # https://github.com/nvim-tree/nvim-web-devicons/
      # https://nix-community.github.io/nixvim/plugins/web-devicons
      web-devicons = {
        enable = true;
        lazyLoad.enable = config.lazyLoad.enable;
        lazyLoad.settings.event = "DeferredUIEnter";
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      rhubarb # allows easily opening things in github
      vim-smoothie # smooth scrolling
    ];
  };
}
