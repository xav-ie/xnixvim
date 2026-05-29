{ config, ... }:
{
  config = {
    # magit-like git interface for neovim
    # https://github.com/NeogitOrg/neogit
    # https://nix-community.github.io/nixvim/plugins/neogit
    # Required by Neogit's diffview integration; opens hunks/files in a proper
    # side-by-side diff with filetype syntax highlighting.
    # https://github.com/sindrets/diffview.nvim
    plugins.diffview = {
      enable = true;
      settings = {
        enhanced_diff_hl = true;
        view = {
          default.winbar_info = true;
          merge_tool.layout = "diff3_mixed";
        };
      };
    };

    plugins.neogit = {
      enable = true;
      lazyLoad.enable = config.lazyLoad.enable;
      lazyLoad.settings = {
        cmd = "Neogit";
        keys = [ "<leader>g" ];
      };
      settings = {
        graph_style = "unicode";
        # Despite the docs claiming this is on by default, it isn't.
        # https://github.com/NeogitOrg/neogit/issues/1964
        treesitter_diff_highlight = true;
        kind = "replace";
        commit_editor.kind = "floating";
        auto_show_console = true;
        console_timeout = 1000;
        fetch_after_checkout = true;
        commit_date_format = "%Y-%m-%d %H:%M";
        log_date_format = "%Y-%m-%d";
        signs = {
          section = [
            ""
            ""
          ];
          item = [
            ""
            ""
          ];
        };
        integrations = {
          telescope = true;
          diffview = true;
        };
        mappings.status = {
          # Free <Tab> for global BufferLineCycleNext.
          "<tab>" = false;
          ">" = "OpenFold";
          "<" = "CloseFold";
        };
      };
    };

    # Neogit's status buffer is unlisted by default, so it never shows up in
    # bufferline. List it so the "Git" group entry appears as a tab.
    autoCmd = [
      {
        event = "FileType";
        pattern = "NeogitStatus";
        callback.__raw = # lua
          ''
            function(args)
              vim.bo[args.buf].buflisted = true
            end
          '';
      }
    ];

    keymaps = [
      {
        mode = "n";
        key = "<leader>g";
        action = "<cmd>Neogit<CR>";
        options.desc = "Neogit";
      }
    ];
  };
}
