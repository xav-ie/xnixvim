{ helpers, lib, ... }:
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
          silent = true;
          desc = "Previous hunk";
        };
        action = # lua
          ''
            function() 
              if vim.wo.diff then return "[c" end
              vim.schedule(function() require("gitsigns").prev_hunk() end)
              return '<Ignore>'
            end
          '';
        lua = true;
      };
      "]c" = {
        options = {
          silent = true;
          desc = "Next hunk";
        };
        action = # lua
          ''
            function() 
              if vim.wo.diff then return "]c" end
              vim.schedule(function() require("gitsigns").next_hunk() end)
              return '<Ignore>'
            end
          '';
        lua = true;
      };
      "<leader>hb" = {
        options = {
          silent = true;
          desc = "[b]lame Full Line";
        };
        action = # lua
          ''function() require("gitsigns").blame_line{full=true} end'';
        lua = true;
      };
      "<leader>hd" = {
        options = {
          silent = true;
          desc = "[d]iff This";
        };
        action = # lua
          ''function() require("gitsigns").diffthis() end'';
        lua = true;
      };
      "<leader>hD" = {
        options = {
          silent = true;
          desc = "[D]iff This ~";
        };
        action = # lua
          ''function() require("gitsigns").diffthis("~") end'';
        lua = true;
      };
      "<leader>hp" = {
        options = {
          silent = true;
          desc = "[p]review Hunk";
        };
        action = # lua
          ''function() require("gitsigns").preview_hunk() end'';
        lua = true;
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
        action = # lua
          ''function() require("gitsigns").reset_buffer() end'';
        lua = true;
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
        action = # lua
          ''function() require("gitsigns").stage_buffer() end'';
        lua = true;
      };
      "<leader>hu" = {
        options = {
          silent = true;
          desc = "[u]ndo Stage Hunk";
        };
        action = # lua
          ''function() require("gitsigns").undo_stage_hunk() end'';
        lua = true;
      };
      "<leader>tb" = {
        options = {
          silent = true;
          desc = "Toggle Line [b]lame";
        };
        action = # lua
          ''function() require("gitsigns").toggle_current_line_blame() end'';
        lua = true;
      };
      "<leader>td" = {
        options = {
          silent = true;
          desc = "Toggle [d]eleted";
        };
        action = # lua
          ''function() require("gitsigns").toggle_deleted() end'';
        lua = true;
      };
    })
    ++ (ox {
      "ih" = {
        action = ":<C-U>Gitsigns select_hunk<CR>";
        options.desc = "[h]unk";
      };
    });
}
