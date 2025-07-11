{
  pkgs,
  # neovim-nightly-overlay,
  # system,
  ...
}:
{
  config = {
    colorschemes = {
      base16 = {
        enable = true;
        #colorscheme = "pinky";
        #colorscheme = "colors";
        #colorscheme = "purpledream";
        # somehow, gatekeeper theme from nvchad is based on pico
        # but this looks bad, but I love gatekeeper
        #colorscheme = "pico";
        colorscheme = {
          # background
          base00 = "NONE";
          # active tab, ui tab foreground
          base01 = "#603090";
          # highlight text color
          base02 = "#1060ee";
          # comments
          base03 = "#a090a0";
          # line number color
          base04 = "#a0a0ff";
          # special characters ()=>{}
          base05 = "#e0e0e0";
          # ???
          base06 = "#00ff00";
          # ???
          base07 = "#a0a000";
          # html tags, variables, attributes, ui tab background
          base08 = "#FFB20F";
          # values
          base09 = "#00a0f0";
          # types, html attributes
          base0A = "#BE620A";
          # strings, unsaved tab, ui tab background
          base0B = "#00E756";
          # ???
          base0C = "#FFD242";
          # values
          base0D = "#9A5FEB";
          # keywords, function calls
          base0E = "#ff3a8e";
          # special characters, semi-colons, commas
          base0F = "#f06949";
        };
      };
    };

    # Temporarily disable neovim-nightly-overlay because it is causing these
    # plugins to misbehave:
    # - oil - broken from lualine
    # - lualine - breaking oil buffers
    # - telescope - search not populating
    # - gitsigns - always causes exit 1 for nvim
    # - vim-matchup? - buffers not updating properly
    # package = neovim-nightly-overlay.packages."${system}".default;

    extraPackages = with pkgs; [
      coq
      git
      nixfmt-rfc-style
      ripgrep
      stylua
      # vimPlugins.friendly-snippets
    ];

    # vim.g[...]
    globals = {
      mapleader = " ";
      neovide_window_blurred = true;
      neovide_cursor_vfx_mode = "pixiedust";
      # only applies when launched with --no-vsync.
      # sometimes improves animations
      neovide_refresh_rate = 144;
      neovide_scale_factor = 1.1;
      neovide_touch_deadzone = 0.0;
      neovide_transparency = 0.7;
      # These two seem to have no effect (maybe on MacOS?):
      # neovide_text_gamma = 3.4;
      # neovide_text_contrast = 2.0;
      # 24-bit colors
      termguicolors = true;
      # don't care about case when search
      ignorecase = true;
      # ...unless you used uppercase
      smartcase = true;
    };

    # match = {
    #   ColorColumn = "\\%101v";
    # };

    # vim.opt[...]
    # THERE IS NO WAY TO SET VISUAL LINE BREAK WIDTH?!?
    # https://www.reddit.com/r/neovim/comments/1anwa1y/nondestructively_set_line_wrap_width/
    opts = {
      cmdheight = 1;
      showmode = false;
      expandtab = true;
      guifont = "Maple Mono NF:h14";
      linebreak = true; # visually wrap lines by word, not char
      number = true; # Show line numbers
      relativenumber = false;
      scrolloff = 2; # min number of lines to keep above and below cursor. default is 0
      shiftwidth = 2; # Tab width should be 2
      showbreak = "→"; # prefix for wrapped lines
      smartindent = true;
      softtabstop = 2;
      # spell = true;
      # Not currently working.
      # TODO: See other configurations on GitHub.
      spellfile = "~/.config/nvim/spell/en_us.utf-8.add";
      spelllang = "en_us";
      tabstop = 2;
      # corrects command auto-complete to first show the completion list, then further tabs
      # will cause complete auto-complete
      wildmode = "list,full";
    };

    performance = {
      byteCompileLua = {
        enable = true;
        configs = true;
        initLua = true;
        nvimRuntime = true;
        plugins = false;
      };
      combinePlugins.enable = true;
      combinePlugins.standalonePlugins = [
        "firenvim"
        "conform.nvim"
        "oil.nvim"
        "nvim-treesitter"
        "lualine.nvim"
        # TODO: move out somehow
        "telescope.nvim"
        "telescope-symbols.nvim"
        # TODO: move out somehow
        "friendly-snippets"
        "luasnip"
        "minuet-ai.nvim"
      ];
    };
  };
}
