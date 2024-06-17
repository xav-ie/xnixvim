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
      # merge statusbar into command bar
      # ...except, this does not work :/
      # cmdheight = 0;
      mapleader = " ";
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

    opts = {
      number = true; # Show line numbers
      relativenumber = false;
      shiftwidth = 2; # Tab width should be 2
      tabstop = 2;
      softtabstop = 2;
      smartindent = true;
      expandtab = true;
    };
  };
}
