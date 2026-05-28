{
  config,
  lib,
  ...
}:
let
  aiProvider = config.programs.ai-completion-provider;
in
{
  # completions
  # https://github.com/Saghen/blink.cmp
  # https://nix-community.github.io/nixvim/plugins/blink-cmp
  config = {
    # Stub blink-cmp module early so the setup call (and the LSP capabilities
    # snippet) don't error at startup when the plugin is lazy-loaded into opt/
    # via lz.n. The stub gets cleared right before lz.n's real setup runs.
    extraConfigLuaPre = lib.mkIf config.lazyLoad.enable ''
      package.preload['blink-cmp'] = function()
        return setmetatable({}, {
          __index = function() return function() end end
        })
      end
    '';

    plugins.blink-cmp = {
      enable = true;
      lazyLoad.enable = config.lazyLoad.enable;
      lazyLoad.settings.event = "InsertEnter";

      # Clear the preload stub so the real blink-cmp module loads on packadd
      luaConfig.pre = ''
        package.loaded['blink-cmp'] = nil
        package.preload['blink-cmp'] = nil
      '';

      settings = {
        # Mirror cmp.nix bindings 1:1 rather than inheriting the "default" preset:
        # the preset binds <C-y> to select_and_accept which collides with
        # cursortab's accept keymap.
        keymap = {
          "<C-u>" = [
            "scroll_documentation_up"
            "fallback"
          ];
          "<C-d>" = [
            "scroll_documentation_down"
            "fallback"
          ];
          "<C-Space>" = [
            "show"
            "show_documentation"
            "hide_documentation"
          ];
          "<C-n>" = [
            "select_next"
            "fallback"
          ];
          "<C-p>" = [
            "select_prev"
            "fallback"
          ];
          "<CR>" = [
            "accept"
            "fallback"
          ];
        }
        # Tab is used by cursortab for accepting completions
        // lib.optionalAttrs (aiProvider != "cursortab") {
          "<Tab>" = [
            "hide"
            "fallback"
          ];
        }
        // lib.optionalAttrs (aiProvider == "minuet") {
          "<A-y>".__raw = "require('minuet').make_blink_map()";
        };

        snippets.preset = "luasnip";

        # Function-signature/parameter hints while typing inside `(...)`.
        signature.enabled = true;

        # Ex-mode (`:`) completion: blink completes commands, args, buffers, etc.
        cmdline = {
          keymap.preset = "cmdline";
          completion.menu.auto_show = true;
        };

        # Make blink fall back to CmpItemKind* highlight groups (defined in
        # xdusk) so each kind keeps its distinct fg color instead of every
        # row sharing BlinkCmpLabel's default fg.
        appearance.use_nvim_cmp_as_default = true;

        completion = {
          # winborder (config.nix) draws a border on every float, including the
          # completion menu. Force it off here so the menu stays borderless.
          menu = {
            border = "none";
            draw.columns = [
              {
                __unkeyed-1 = "label";
                __unkeyed-2 = "label_description";
                gap = 1;
              }
              {
                __unkeyed-1 = "kind_icon";
                __unkeyed-2 = "kind";
                gap = 1;
              }
              { __unkeyed-1 = "source_name"; }
            ];
          };
          # Auto-show docs preview next to the menu while cycling items.
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
          };
        };

        sources = {
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
          ]
          ++ lib.optional (aiProvider == "minuet") "minuet";
          providers = {
            buffer.opts.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
          }
          // lib.optionalAttrs (aiProvider == "minuet") {
            minuet = {
              name = "minuet";
              module = "minuet.blink";
              score_offset = 8;
              async = true;
              # was performance.fetching_timeout in cmp.nix
              timeout_ms = 3000;
            };
          };
        };
      };
    };
    # Completion-menu kind colors were extracted into the xdusk colorscheme
    # (custom-plugins/xdusk).
  };
}
