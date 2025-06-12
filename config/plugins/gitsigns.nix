{
  config,
  helpers,
  lib,
  ...
}:
{
  # https://github.com/lewis6991/gitsigns.nvim/
  # https://nix-community.github.io/nixvim/plugins/gitsigns
  config = {
    # git indicators in the left gutter
    plugins.gitsigns = {
      enable = true;
      lazyLoad.settings.event = "BufEnter";
      lazyLoad.enable = config.lazyLoad.enable;
      settings = {
        current_line_blame = true;
        current_line_blame_opts = {
          virt_text = true;
          virt_text_pos = "right_align";
          delay = 0;
          ignore_whitespace = false;
          virt_text_priority = 100;
        };
        numhl = true;
        # TODO: comb through and make better
        # https://github.com/fpletz/flake/blob/f97512e2f7cfb555bcebefd96f8cf61155b8dc42/home/nixvim/gitsigns.nix#L21
      };
    };
    # TODO: deduplicate somehow
    keymaps =
      let
        modeKeys =
          mode:
          lib.attrsets.mapAttrsToList (
            key: action:
            { inherit key mode; } // (if builtins.isString action then { inherit action; } else action)
          );
        nm = modeKeys [ "n" ];
        ox = modeKeys [
          "o"
          "x"
        ];
      in
      helpers.keymaps.mkKeymaps { options.silent = true; } (nm {
        "[c" = {
          options = {
            desc = "Previous hunk";
          };
          action.__raw = # lua
            ''
              function()
                if vim.wo.diff then return "[c" end
                vim.schedule(function() require("gitsigns").nav_hunk('prev', {target = 'all'}) end)
                return '<Ignore>'
              end
            '';
        };
        "]c" = {
          options = {
            desc = "Next hunk";
          };
          action.__raw = # lua
            ''
              function()
                if vim.wo.diff then return "]c" end
                vim.schedule(function() require("gitsigns").nav_hunk('next', {target = 'all'}) end)
                return '<Ignore>'
              end
            '';
        };
        "<leader>hb" = {
          options = {
            silent = true;
            desc = "[b]lame Full Line";
          };
          action.__raw = # lua
            ''function() require("gitsigns").blame_line{full=true} end'';
        };
        "<leader>hd" = {
          options = {
            silent = true;
            desc = "[d]iff This";
          };
          action.__raw = # lua
            ''function() require("gitsigns").diffthis() end'';
        };
        "<leader>hD" = {
          options = {
            silent = true;
            desc = "[D]iff This ~";
          };
          action.__raw = # lua
            ''function() require("gitsigns").diffthis("~") end'';
        };
        "<leader>hp" = {
          options = {
            silent = true;
            desc = "[p]review Hunk";
          };
          action.__raw = # lua
            ''function() require("gitsigns").preview_hunk() end'';
        };
        "<leader>hr" = {
          action = ":Gitsigns reset_hunk<CR>";
          options.desc = "[r]eset Hunk";
        };
        "<leader>hR" = {
          options = {
            silent = true;
            desc = "[R]eset Buffer";
          };
          action.__raw = # lua
            ''function() require("gitsigns").reset_buffer() end'';
        };
        "<leader>hs" = {
          action = ":Gitsigns stage_hunk<CR>";
          options.desc = "[s]tage Hunk";
        };
        "<leader>hS" = {
          options = {
            silent = true;
            desc = "[S]tage Buffer";
          };
          action.__raw = # lua
            ''function() require("gitsigns").stage_buffer() end'';
        };
        "<leader>hu" = {
          options = {
            silent = true;
            desc = "[u]ndo Stage Hunk";
          };
          action.__raw = # lua
            ''function() require("gitsigns").undo_stage_hunk() end'';
        };
        "<leader>tb" = {
          options = {
            silent = true;
            desc = "Toggle Line [b]lame";
          };
          action.__raw = # lua
            ''function() require("gitsigns").toggle_current_line_blame() end'';
        };
        "<leader>td" = {
          options = {
            silent = true;
            desc = "Toggle [d]eleted";
          };
          action.__raw = # lua
            ''function() require("gitsigns").toggle_deleted() end'';
        };
      })
      ++ (ox {
        "ih" = {
          action = ":<C-U>Gitsigns select_hunk<CR>";
          options.desc = "[h]unk";
        };
      });
  };
}
