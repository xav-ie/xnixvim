{ ... }:
{
  # git indicators in the left gutter
  plugins.gitsigns = {
    enable = true;
    settings = {
      current_line_blame = true;
      current_line_blame_opts = {
        virt_text = true;
        virt_text_pos = "right_align";
        delay = 0;
        ignore_whitespace = false;
        virt_text_priority = 100;
      };
      # TODO: comb through and make better
      # https://github.com/fpletz/flake/blob/f97512e2f7cfb555bcebefd96f8cf61155b8dc42/home/nixvim/gitsigns.nix#L21
      # TODO: make this not depend on which-key
      on_attach = # lua
        ''
          function(bufnr)
            local gs = package.loaded.gitsigns

            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end

            -- Register key mappings and descriptions using which-key
            local wk = require("which-key")
            wk.register({
                ["]c"] = { function()
                    if vim.wo.diff then return "]c" end
                    vim.schedule(function() gs.next_hunk() end)
                    return '<Ignore>'
                end, "Next Hunk" },
                ["[c"] = { function()
                    if vim.wo.diff then return "[c" end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                end, "Previous Hunk" },
                ["<leader>"] = {
                    h = {
                        name = "+[h]unk",
                        s = { ":Gitsigns stage_hunk<CR>", "[s]tage Hunk" },
                        r = { ":Gitsigns reset_hunk<CR>", "[r]eset Hunk" },
                        S = { gs.stage_buffer, "[S]tage Buffer" },
                        u = { gs.undo_stage_hunk, "[u]ndo Stage Hunk" },
                        R = { gs.reset_buffer, "[R]eset Buffer" },
                        p = { gs.preview_hunk, "[p]review Hunk" },
                        b = { function() gs.blame_line{full=true} end, "[b]lame Full Line" },
                        d = { gs.diffthis, "[d]iff This" },
                        D = { function() gs.diffthis('~') end, "[D]iff This ~" },
                    },
                    t = {
                        name = "+[t]oggle",
                        b = { gs.toggle_current_line_blame, "Toggle Line [b]lame" },
                        d = { gs.toggle_deleted, "Toggle [d]eleted" },
                    }
                }
            }, { mode = "n", buffer = bufnr, silent = true, noremap = true, nowait = true })

            -- Text object
            map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
          end
        '';
    };
  };
}
