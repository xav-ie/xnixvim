{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./bgwinch.nix
    ./blink-cmp.nix
    ./bufferline.nix
    ./codediff.nix
    ./colorful-menu.nix
    ./conform-nvim.nix
    ./direnv.nix
    ./fff.nix
    ./flash.nix
    ./flatten.nix

    # ./firenvim.nix
    ./fugitive.nix
    ./git-heat.nix
    ./gitsigns.nix
    ./himalaya.nix
    ./inc-rename.nix
    ./jjdescription.nix
    ./lsp
    ./lazydev.nix
    ./lsp-lines.nix
    ./lualine.nix
    ./luasnip.nix
    ./markdown-table-sorter.nix
    ./markview.nix
    ./completion-providers
    ./neogit.nix
    ./noice.nix
    ./notify.nix
    ./nvim-colorizer.nix
    # ./nvim-lightbulb.nix
    ./nvim-scrollview.nix
    ./oil-git-status.nix
    ./oil.nix
    # ./ollama.nix
    ./quicker.nix
    # ./supermaven.nix
    ./tabscope.nix
    ./telescope
    ./tiny-glimmer.nix
    ./toggleterm.nix
    ./treesitter.nix
    # TODO: fix
    # ./vim-guise.nix
    ./vim-matchup.nix
    ./which-key
    ./witt-neovim.nix
    ./xdusk.nix
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

      # amazing snippets for every language
      # https://github.com/rafamadriz/friendly-snippets
      # https://nix-community.github.io/nixvim/plugins/friendly-snippets
      friendly-snippets.enable = true;

      # adds syntax highlighting and special helpers for nix files
      # https://github.com/LnL7/vim-nix/
      # https://nix-community.github.io/nixvim/plugins/nix
      # nix.enable = true;
      # TODO: test

      # auto-pairs + rainbow highlighting in one Rust-parsed plugin
      # https://github.com/saghen/blink.pairs/
      # https://nix-community.github.io/nixvim/plugins/blink-pairs
      blink-pairs = {
        enable = true;
        lazyLoad.enable = config.lazyLoad.enable;
        lazyLoad.settings.event = [
          "BufReadPost"
          "BufNewFile"
        ];
        settings = {
          mappings.enabled = true;
          highlights = {
            enabled = true;
            groups = [
              "RainbowDelimiterRed"
              "RainbowDelimiterYellow"
              "RainbowDelimiterBlue"
              "RainbowDelimiterOrange"
              "RainbowDelimiterGreen"
              "RainbowDelimiterViolet"
            ];
            unmatched_group = "BlinkPairsUnmatched";
            matchparen.group = "MatchParen";
          };
        };
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
      vim-rhubarb # allows easily opening things in github
      vim-smoothie # smooth scrolling
    ];
  };
}
