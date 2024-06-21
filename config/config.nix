{
  pkgs,
  neovim-nightly-overlay,
  system,
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

    package = neovim-nightly-overlay.packages."${system}".default;

    extraPackages = with pkgs; [
      git
      nixfmt-rfc-style
      ripgrep
      stylua
      # vimPlugins.friendly-snippets
    ];

    globals = {
      mapleader = " ";
      # TODO: add MacOS specific neovide config
      neovide_cursor_vfx_mode = "pixiedust";
      # only applies when launched with --no-vsync.
      # sometimes improves animations
      neovide_refresh_rate = 144;
      neovide_scale_factor = 1.1;
      neovide_touch_deadzone = 0.0;
      neovide_transparency = 0.8;
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
    opts = {
      cmdheight = 0;
      expandtab = true;
      number = true; # Show line numbers
      relativenumber = false;
      shiftwidth = 2; # Tab width should be 2
      smartindent = true;
      softtabstop = 2;
      tabstop = 2;
      # spell = true;
      # Not currently working. 
      # TODO: See other configurations on GitHub.
      spellfile = "~/.config/nvim/spell/en_us.utf-8.add";
      spelllang = "en_us";
      # corrects command auto-complete to first show the completion list, then further tabs 
      # will cause complete auto-complete 
      wildmode = "list,full";
    };
  };
}
