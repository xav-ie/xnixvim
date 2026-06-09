{
  config,
  lib,
  ...
}:
{
  # Yank ring + history. Records every yank (persisted via ShaDa), highlights
  # put/yank regions, and lets you cycle through previous yanks after a paste.
  # https://github.com/gbprod/yanky.nvim
  # https://nix-community.github.io/nixvim/plugins/yanky
  config = {
    # tiny-glimmer ⇄ yanky bridge. tiny-glimmer's generic auto_map hijack can't
    # wrap yanky's <Plug> maps (it replays them noremap), so instead we drive
    # tiny-glimmer's animation API directly off yanky's own seams:
    #   - put: yanky calls highlight.highlight_put(state) after every put/cycle
    #     (yanky.lua), computing the region from the '[ '] marks. We replace that
    #     function with a glimmer fade over the same marks.
    #   - yank: a TextYankPost autocmd animates the just-yanked region.
    # This keeps yanky owning p/P/y (ring intact) while restoring glimmer fades.
    extraConfigLua = # lua
      ''
        do
          local PUT_COLOR  = "#FFD242" -- palette base0C (golden), matches old fade
          local YANK_COLOR = "#FFD242"
          local DURATION   = 700

          local function bg_hex()
            local hl = vim.api.nvim_get_hl(0, { name = "Normal" })
            return hl.bg and string.format("#%06x", hl.bg) or "#000000"
          end

          -- Animate the current change region ('[ to ']) with a glimmer fade.
          local function animate(from_color, regtype)
            local ok, glimmer = pcall(require, "tiny-glimmer.lib")
            if not ok then return end
            local s = vim.api.nvim_buf_get_mark(0, "[")
            local e = vim.api.nvim_buf_get_mark(0, "]")
            if s[1] == 0 or e[1] == 0 then return end
            local opts = {
              range = {
                start_line = s[1] - 1, start_col = s[2],
                end_line   = e[1] - 1, end_col   = e[2] + 1,
              },
              effect = "fade",
              duration = DURATION,
              from_color = from_color,
              to_color = bg_hex(),
            }
            local linewise = (regtype or ""):sub(1, 1) == "V"
            pcall(linewise and glimmer.create_line_animation or glimmer.create_animation, opts)
          end

          -- Swap yanky's put-highlight for a glimmer fade. Retried on buffer
          -- events until yanky is actually loaded (it lazy-loads), then the
          -- installer autocmd removes itself.
          local install_id
          local function install_put()
            local ok, hl = pcall(require, "yanky.highlight")
            if not ok then return false end
            hl.highlight_put = function(state)
              animate(PUT_COLOR, vim.fn.getregtype(state.register))
            end
            return true
          end
          install_id = vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
            desc = "Install tiny-glimmer put animation into yanky",
            callback = function()
              if install_put() and install_id then
                pcall(vim.api.nvim_del_autocmd, install_id)
                install_id = nil
              end
            end,
          })

          -- Yank animation (yanky's own on_yank is off).
          vim.api.nvim_create_autocmd("TextYankPost", {
            desc = "tiny-glimmer fade on yank",
            callback = function()
              if vim.v.event.operator == "y" then
                animate(YANK_COLOR, vim.v.event.regtype)
              end
            end,
          })
        end
      '';

    plugins.yanky = {
      enable = true;
      lazyLoad.enable = config.lazyLoad.enable;
      # Remaps p/y below need the plugs available, so load on first edit.
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
      settings = {
        # Persist the ring across sessions without the sqlite dependency.
        ring.storage = "shada";
        # yanky's plain highlight is disabled — tiny-glimmer renders the
        # put/yank animation instead (wired up in extraConfigLua below).
        highlight = {
          on_put = false;
          on_yank = false;
        };
      };
    };

    keymaps = lib.nixvim.keymaps.mkKeymaps { options.silent = true; } [
      # Route yanks/puts through yanky so the ring stays populated. The OSC52
      # clipboard sync (extraConfigLua.nix) hooks TextYankPost independently and
      # is unaffected.
      {
        mode = [
          "n"
          "x"
        ];
        key = "y";
        action = "<Plug>(YankyYank)";
        options.desc = "Yank (yanky)";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "p";
        action = "<Plug>(YankyPutAfter)";
        options.desc = "Put after (yanky)";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "P";
        action = "<Plug>(YankyPutBefore)";
        options.desc = "Put before (yanky)";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "gp";
        action = "<Plug>(YankyGPutAfter)";
        options.desc = "Put after, cursor after (yanky)";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "gP";
        action = "<Plug>(YankyGPutBefore)";
        options.desc = "Put before, cursor after (yanky)";
      }
      # Cycle through the ring after a put. <C-n>/<C-p> are taken (tree-sitter
      # node-select / completion), so use Alt to avoid collisions.
      {
        mode = "n";
        key = "<M-p>";
        action = "<Plug>(YankyPreviousEntry)";
        options.desc = "Yank ring: previous entry";
      }
      {
        mode = "n";
        key = "<M-n>";
        action = "<Plug>(YankyNextEntry)";
        options.desc = "Yank ring: next entry";
      }
      # Browse the full yank history (telescope picker via the YankyRingHistory
      # command).
      {
        mode = "n";
        key = "<leader>yh";
        action = "<cmd>YankyRingHistory<CR>";
        options.desc = "[y]ank: history";
      }
    ];
  };
}
