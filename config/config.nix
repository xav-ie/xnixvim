{
  pkgs,
  # neovim-nightly-overlay,
  # system,
  ...
}:
{
  config = {
    # Colorscheme lives in plugins/xdusk.nix (custom-plugins/xdusk). The base16
    # palette and every per-plugin highlight tweak were extracted into that
    # self-contained theme; the slot meanings are documented in its palette.lua.

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
      nixfmt
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
      numberwidth = 3; # Fixed-width number column to prevent jitter on file open
      showtabline = 2; # Always show tabline to prevent content shift on buffer open
      tabline = " "; # Blank tabline until bufferline loads
      signcolumn = "yes"; # Always show sign column to prevent jitter
      relativenumber = false;
      scrolloff = 2; # min number of lines to keep above and below cursor. default is 0
      shiftwidth = 2; # Tab width should be 2
      showbreak = "→"; # prefix for wrapped lines
      smartindent = true;
      softtabstop = 2;
      # `spell` is intentionally left off globally — it would underline every
      # identifier/keyword in code. It's enabled per-buffer for prose filetypes
      # via the proseSpell autocmd in extraConfigLua.nix.
      spellfile = "~/.config/nvim/spell/en_us.utf-8.add";
      spelllang = "en_us";
      tabstop = 2;
      # corrects command auto-complete to first show the completion list, then further tabs
      # will cause complete auto-complete
      wildmode = "list,full";
      winborder = "single"; # default border for floating windows
    };

    performance = {
      byteCompileLua = {
        enable = true;
        configs = true;
        initLua = true;
        nvimRuntime = true;
        # breaks lazydev type resolution
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
        # Keeps VERSION + libvscode_diff_*.dylib at the plugin root where
        # codediff's runtime expects them (the combined plugin-pack only
        # copies lua/, plugin/, doc/, etc.).
        "codediff.nvim"
      ];
    };
  };
}
