{ config, pkgs, ... }:
let
  # fff has no per-side border option (borders come only from vim.o.winborder
  # presets). Patch build_window_configs to remove the *outer* frame
  # (far-left, far-right, bottom) while keeping the top title bar, the line
  # under the prompt, and the list/preview divider — the ivy look.
  #
  # An "" border side draws nothing AND reserves no cell, so nvim keeps the
  # content where it was and the buffer shows through the old border cell.
  # So after blanking the outer sides we resize each window to fill the
  # reclaimed space: the left column to screen col 0, the preview right to
  # the last column, and the list/preview bottoms down to just above the
  # statusline. The renderer reads the live window size, so it fills. The
  # divider (list right border + preview left border) is left where fff put
  # it, and the top title/prompt-separator borders are kept.
  #
  # Sides are nvim 8-element border index {1 tl, 2 top, 3 tr, 4 right,
  # 5 br, 6 bottom, 7 bl, 8 left}. The anchor line is matched with
  # --replace-fail: a fff bump that changes it fails the build loudly
  # instead of silently no-op-ing. Caveat: --replace-fail only guards the
  # anchor *line* — this patch is also coupled to 0.6.4's border-index
  # layout, so a future fff that keeps the line but reorders the border
  # arrays would patch successfully yet produce wrong borders. Re-verify the
  # indices against picker_ui.lua build_window_configs when bumping fff.
  #
  # NOTE: assumes this config layout (preview right, prompt top). Changing
  # preview_position/prompt_position would need this revisited.
  fff-nvim = pkgs.vimPlugins.fff-nvim.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace lua/fff/picker_ui.lua \
        --replace-fail \
        'local win_configs = build_window_configs(layout, config)' \
        'local win_configs = build_window_configs(layout, config)
      do
        local cols = vim.o.columns
        local bottom = vim.o.lines - vim.o.cmdheight - (vim.o.laststatus > 0 and 1 or 0) - 1
        local function blank(b, idx) for _, i in ipairs(idx) do b[i] = "" end end
        local input, list, preview = win_configs.input, win_configs.list, win_configs.preview
        if list and type(list.border) == "table" then
          blank(list.border, { 1, 5, 6, 7, 8 })
          list.width = list.col + list.width  -- keep right border (divider) col
          list.col = 0
          list.height = bottom - list.row + 1
        end
        if input and type(input.border) == "table" then
          blank(input.border, { 1, 8 })
          input.width = input.col + input.width
          input.col = 0
        end
        if preview and type(preview.border) == "table" then
          blank(preview.border, { 3, 4, 5, 6, 7 })
          preview.width = cols - preview.col  -- keep left border (divider) col
          preview.height = bottom - preview.row + 1
        end
      end'
    '';
  });
in
{
  # Fast, Rust-backed, frecency-ranked file finder + live grep
  # https://github.com/dmtrKovalenko/fff.nvim/
  # https://nix-community.github.io/nixvim/plugins/fff
  config = {
    plugins.fff = {
      enable = true;
      package = fff-nvim;
      # Match the old Telescope ivy/bottom_pane look: bottom-docked, full
      # width, half height, prompt on top (results ascending below).
      settings.layout = {
        anchor = "bottom";
        width = 1.0;
        height = 0.7;
        prompt_position = "top";
        preview_position = "right";
        # Keep the preview on the right at any width. fff's flex layout
        # otherwise flips it on top below 130 cols, which at height 0.5
        # collapses the list window to 0 rows and crashes nvim_open_win.
        flex.size = 0;
      };
      lazyLoad.enable = config.lazyLoad.enable;
      # lz.n registers these keymaps and loads + runs fff on first press.
      lazyLoad.settings.keys = [
        {
          __unkeyed-1 = "<leader>ff";
          __unkeyed-2.__raw = "function() require('fff').find_files() end";
          mode = "n";
          desc = "fff find_[f]iles";
        }
        {
          __unkeyed-1 = "<leader>fl";
          __unkeyed-2.__raw = "function() require('fff').live_grep() end";
          mode = "n";
          desc = "fff [l]ive_grep";
        }
      ];
    };
  };
}
