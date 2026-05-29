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
          preset = "none";
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
            "show"
            "select_next"
            "fallback"
          ];
          "<C-p>" = [
            "select_prev"
            "fallback"
          ];
          "<CR>" = [
            (
              if config.plugins.tiny-glimmer.enable then
                {
                  __raw = # lua
                    ''
                      function(cmp)
                        local before = vim.api.nvim_win_get_cursor(0)
                        local accepted = cmp.accept()
                        if accepted then
                          vim.schedule(function()
                            local after = vim.api.nvim_win_get_cursor(0)
                            local before_row, after_row = before[1] - 1, after[1] - 1
                            local start_row = math.min(before_row, after_row)
                            local end_row   = math.max(before_row, after_row)
                            local start_col, end_col
                            if before_row == after_row then
                              start_col = math.min(before[2], after[2])
                              end_col   = math.max(before[2], after[2])
                            else
                              start_col = 0
                              end_col   = vim.fn.col({ end_row + 1, "$" }) - 1
                            end
                            if start_row == end_row and start_col == end_col then return end
                            local ok, glimmer = pcall(require, "tiny-glimmer.lib")
                            if not ok then return end
                            glimmer.create_animation({
                              range = {
                                start_line = start_row,
                                start_col  = start_col,
                                end_line   = end_row,
                                end_col    = end_col,
                              },
                              duration   = 600,
                              from_color = "#00a0f0",
                              to_color   = "Normal",
                              effect     = "fade",
                              easing     = "linear",
                            })
                          end)
                        end
                        return accepted
                      end
                    '';
                }
              else
                "accept"
            )
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
            draw = {
              # colorful-menu folds label_description into label, so it's
              # omitted from the column list here.
              columns = [
                {
                  __unkeyed-1 = "label";
                  gap = 1;
                }
                {
                  __unkeyed-1 = "kind_icon";
                  __unkeyed-2 = "kind";
                  gap = 1;
                }
                { __unkeyed-1 = "source_name"; }
              ];
              components.label = {
                text.__raw = "function(ctx) return require('colorful-menu').blink_components_text(ctx) end";
                highlight.__raw = "function(ctx) return require('colorful-menu').blink_components_highlight(ctx) end";
              };
            };
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
            # Default score_offset is -3, which pushes snippets below buffer
            # matches even on close prefix hits. Bump above buffer (default 0).
            snippets.score_offset = 5;
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
