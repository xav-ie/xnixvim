{ config, ... }:
{
  config = {
    # smooth, customizable animations for yank/paste/search/undo/redo
    # https://github.com/rachartier/tiny-glimmer.nvim
    # https://nix-community.github.io/nixvim/plugins/tiny-glimmer
    #
    # Search animation is wired up manually below instead of via
    # overwrite.search.enabled: the plugin's animation extmark uses
    # hl_mode = "blend" which mathematically mixes the pulse color into
    # CurSearch.bg, washing out the pulse against any non-transparent bg.
    # Patching the plugin to use "replace" + high priority didn't beat
    # CurSearch's internal render layer in practice. So instead:
    #   - leave the plugin's search hijack OFF (keeps CurSearch untouched)
    #   - bind n/N ourselves: clear CurSearch.bg, jump, animate, restore
    # That way CurSearch's purple bg persists between searches AND the
    # pulse renders cleanly against a transparent bg during the animation.
    extraConfigLua = # lua
      ''
        do
          local cursearch_purple = { fg = "#200020", bg = "#9A5FEB" }
          local cursearch_clear  = { fg = "#200020" } -- no bg
          local pulse_ms = 900 -- matches animations.pulse.max_duration
          local restore_timer = nil

          local function restore_cursearch()
            vim.api.nvim_set_hl(0, "CurSearch", cursearch_purple)
          end

          local group = vim.api.nvim_create_augroup("tiny_glimmer_cursearch", { clear = true })
          vim.api.nvim_create_autocmd("ColorScheme", {
            group = group,
            callback = restore_cursearch,
          })

          local function animated_search(direction)
            -- Suppress CurSearch.bg so the blend-mode pulse renders cleanly
            vim.api.nvim_set_hl(0, "CurSearch", cursearch_clear)
            -- Cancel any pending restore from a prior rapid press
            if restore_timer then
              pcall(vim.fn.timer_stop, restore_timer)
              restore_timer = nil
            end

            -- Perform the jump
            local ok = pcall(vim.cmd, "normal! " .. direction)
            if not ok then
              restore_cursearch()
              return
            end

            local pattern = vim.fn.getreg("/")
            if pattern == "" then
              restore_cursearch()
              return
            end

            local cursor = vim.api.nvim_win_get_cursor(0)
            local row = cursor[1]
            local matches = vim.fn.matchbufline(vim.api.nvim_get_current_buf(), pattern, row, row)
            if vim.tbl_isempty(matches) then
              restore_cursearch()
              return
            end

            -- Pick the match that contains (or is closest after) the cursor
            local col = cursor[2]
            local chosen = matches[1]
            for _, m in ipairs(matches) do
              if m.byteidx <= col and col < (m.byteidx + #m.text) then
                chosen = m
                break
              end
            end

            local ok_gl, glimmer = pcall(require, "tiny-glimmer.lib")
            if ok_gl then
              glimmer.create_animation({
                range = {
                  start_line = row - 1,
                  start_col  = chosen.byteidx,
                  end_line   = row - 1,
                  end_col    = chosen.byteidx + #chosen.text,
                },
                duration   = pulse_ms,
                from_color = "#ff3a8e",
                to_color   = "#9A5FEB",
                effect     = "pulse",
                on_complete = restore_cursearch,
              })
            else
              restore_cursearch()
            end

            -- Safety net: if on_complete never fires (e.g. animation
            -- preempted by another action), still restore eventually.
            restore_timer = vim.fn.timer_start(pulse_ms + 200, function()
              restore_cursearch()
              restore_timer = nil
            end)
          end

          vim.keymap.set("n", "n", function() animated_search("n") end,
            { silent = true, desc = "Search next (+ glimmer pulse)" })
          vim.keymap.set("n", "N", function() animated_search("N") end,
            { silent = true, desc = "Search prev (+ glimmer pulse)" })
        end
      '';

    plugins.tiny-glimmer = {
      enable = true;
      lazyLoad.enable = config.lazyLoad.enable;
      # Load on a real-file event, NOT DeferredUIEnter. tiny-glimmer's auto_map
      # hijack captures the *current buffer's* p/u/etc. at load time and promotes
      # them to global maps. Booting straight into Neogit (the `g` alias) makes
      # the neogit status buffer current when DeferredUIEnter fires, so it would
      # capture neogit's buffer-local p=pull / u=unstage globally — breaking
      # paste/undo everywhere. BufReadPost only fires for real files (neogit is
      # nofile), so the hijack always sees a normal buffer's builtin maps.
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
      settings = {
        # xdusk's DiffAdd/DiffDelete use bg = base00 (the editor
        # background), so we pass hex colors from the palette instead —
        # otherwise undo/redo fades would start invisible.
        animations = {
          # `linear` easing keeps the color visible across the full duration
          # instead of decaying in the first ~200ms like outQuad.
          fade = {
            max_duration = 800;
            min_duration = 600;
            easing = "linear";
            chars_for_max_duration = 30;
            from_color = "#FFD242"; # palette base0C (golden yellow)
          };
          pulse = {
            max_duration = 900;
            min_duration = 700;
            chars_for_max_duration = 15;
            pulse_count = 2;
            # intensity * 50 is added to each RGB channel at pulse peaks.
            # 1.6 saturated channels to ~white; 1.0 keeps the pulse vivid
            # without fully bleaching out.
            intensity = 1.0;
            from_color = "#ff3a8e"; # palette base0E (pink)
            to_color = "#9A5FEB"; # palette base0D (xdusk CurSearch bg)
          };
        };
        overwrite = {
          auto_map = true;
          # yank/paste are owned by yanky.nvim (which has its own put/yank
          # highlight). tiny-glimmer's hijack replays the wrapped mapping with
          # feedkeys noremap, but yanky's p/P/y are <Plug> maps that need remap
          # — so wrapping them silently breaks paste. Leave these to yanky.
          yank.enabled = false;
          paste.enabled = false;
          # Manual n/N handler above clears CurSearch.bg around the animation.
          search.enabled = false;
          undo = {
            enabled = true;
            default_animation = {
              name = "fade";
              settings = {
                from_color = "#ff0000"; # palette red
                max_duration = 700;
                min_duration = 700;
              };
            };
          };
          redo = {
            enabled = true;
            default_animation = {
              name = "fade";
              settings = {
                from_color = "#00E756"; # palette base0B (green)
                max_duration = 700;
                min_duration = 700;
              };
            };
          };
        };
      };
    };
  };
}
