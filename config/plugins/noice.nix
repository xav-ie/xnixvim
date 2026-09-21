{
  config,
  pkgs,
  ...
}:
{
  # replace nvim ui with nicer one
  # https://github.com/folke/noice.nvim
  # https://nix-community.github.io/nixvim/plugins/noice
  config = {
    keymaps = [
      {
        key = "<leader><leader>";
        action = "<cmd>Noice dismiss<CR>";
        mode = "n";
        options = {
          silent = true;
          desc = "Dismiss all notifications";
        };
      }
    ];
    plugins.noice = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      lazyLoad.enable = config.lazyLoad.enable;

      # noice's message router ran a `vim.defer_fn` loop at `throttle` for the
      # lifetime of the process. When idle that loop does nothing but compare
      # two integers -- M.update() returns immediately when
      # `M._tick == Manager.tick()` -- so it was a pure poll. The patch has
      # Manager notify the router when the tick actually moves, and lets the
      # loop stop once it has caught up. Message auto-hide is unaffected: views
      # expire on their own one-shot timers, not on this loop.
      package = pkgs.vimPlugins.noice-nvim.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./noice-demand-driven.patch ];
      });
      settings = {
        messages = {
          view = "mini"; # too many info notifications...very annoying!
          # I think these two are good candidates for notifications:
          viewError = "notify";
          viewWarn = "notify";
        };
        lsp = {
          # suppress "No information available." bug
          hover.silent = true;
          override = {
            "vim.lsp.util.convert_input_to_markdown_lines" = true;
            "vim.lsp.util.stylize_markdown" = true;
            "cmp.entry.get_documentation" = true;
          };
        };
        # faulty checks
        health.checker = false;

        # `throttle` is deliberately left at the upstream default (1000/30).
        # With the patch above it only paces the loop while it is actively
        # draining messages, so a larger value buys nothing at idle and only
        # slows burst rendering.

        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
          lsp_doc_border = true;
        };
      };
    };
  };
}
