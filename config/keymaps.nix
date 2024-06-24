# https://github.com/traxys/nvim-flake/blob/c753bb1e624406ef454df9e8cb59d0996000dc93/config.nix#L94-L107
{ helpers, lib, ... }:
{
  keymaps =
    let
      modeKeys =
        mode:
        lib.attrsets.mapAttrsToList (
          key: action:
          { inherit key mode; } // (if builtins.isString action then { inherit action; } else action)
        );
      nm = modeKeys [ "n" ];
      vs = modeKeys [ "v" ];
      im = modeKeys [ "i" ];
      c = modeKeys [ "c" ];
      nxo = modeKeys [
        "n"
        "x"
        "o"
      ];
    in
    helpers.keymaps.mkKeymaps { options.silent = true; } (nm {
      "-" = "<cmd>Oil<CR>";
      # remove highlights
      "<Esc>" = ":noh <CR>";
      # window navigation
      "<C-h>" = "<C-w>h";
      "<C-l>" = "<C-w>l";
      "<C-j>" = "<C-w>j";
      "<C-k>" = "<C-w>k";
      # tab navigation
      "<C-t>l" = ":tabnext <CR>";
      "<C-t>h" = ":tabprev <CR>";
      "<C-t>n" = ":tabnew <CR>:tcd ~/";
      "<C-t>x" = ":tabclose <CR>";
      "<C-t>c" = ":tcd ~/";
      # buffer navigation
      "<tab>" = ":bnext <CR>";
      "<S-tab>" = ":bprevious <CR>";
      # located in ./plugins/tabscope.nix
      # "<leader>x" = ":bdelete <CR>";
      "<leader>/" = {
        action = "<ESC><cmd>lua require('Comment.api').toggle.linewise.current()<CR>";
        options.desc = "Comment Line";
      };
      "<leader>?" = {
        action = "<ESC><cmd>lua require('Comment.api').toggle.blockwise.current()<CR>";
        options.desc = "Comment Line Blockwise";
      };
      "<leader>rn" = {
        mode = [ "n" ];
        action = # lua
          ''function() return ":IncRename " .. vim.fn.expand("<cword>") end'';
        lua = true;
        options = {
          expr = true;
          desc = "Incremental [r]e[n]ame";
        };
      };
    })
    ++ (vs {
      # TODO: find better bindings
      "<leader>/" = {
        action = "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>";
        options.desc = "Comment Linewise";
      };
      "<leader>?" = {
        action = "<ESC><cmd>lua require('Comment.api').toggle.blockwise(vim.fn.visualmode())<CR>";
        options.desc = "Comment Blockwise";
      };
    })
    ++ (im {
      "<C-e>" = "<End>";
      "<C-b>" = "<ESC>^i";
      "<C-h>" = "<Left>";
      "<C-j>" = "<Down>";
      "<C-k>" = "<Up>";
      "<C-l>" = "<Right>";
    })
    # TODO: move flash keymaps into flash plugin?
    ++ (c {
      "<C-s>" = {
        action = # lua
          ''function() require("flash").toggle() end'';
        options = {
          silent = true;
          desc = "Fla[<c-s>]h";
        };
        lua = true;
      };
    })
    ++ (nxo {
      "s" = {
        options = {
          silent = true;
          desc = "Fla[s]h";
        };
        action = # lua
          ''function() require("flash").jump() end'';
        lua = true;
      };
      "S" = {
        options = {
          silent = true;
          desc = "Flash Tree[S]itter";
        };
        action = # lua
          ''function() require("flash").treesitter() end'';
        lua = true;
      };
      "<leader>sr" = {
        options = {
          silent = true;
          desc = "Fla[s]h [r]esume";
        };
        action = # lua
          ''
            function()
              require("flash").jump({continue = true})
            end
          '';
        lua = true;
      };
      "<leader>sc" = {
        options = {
          silent = true;
          desc = "Fla[s]h [c]urrent word";
        };
        action = # lua
          ''
            function()
              require("flash").jump({
                pattern = vim.fn.expand("<cword>"),
              })
            end
          '';
        lua = true;
      };
      "<leader>sl" = {
        options = {
          silent = true;
          desc = "Fla[s]h [l]ine";
        };
        action = # lua
          ''
            function()
              require("flash").jump({
                search = { mode = "search", max_length = 0 },
                label = { after = { 0, 0 } },
                pattern = "^"
              })
            end
          '';
        lua = true;
      };
      "<leader>sw" = {
        options = {
          silent = true;
          desc = "Fla[s]h [w]ord";
        };
        action = # lua
          ''
            function()
              require("flash").jump({
                pattern = ".", -- initialize pattern with any char
                search = {
                  mode = function(pattern)
                    -- remove leading dot
                    if pattern:sub(1, 1) == "." then
                      pattern = pattern:sub(2)
                    end
                    -- return word pattern and proper skip pattern
                    return ([[\<%s\w*\>]]):format(pattern), ([[\<%s]]):format(pattern)
                  end,
                },
                -- select the range
                jump = { pos = "range" },
              })
            end
          '';
        lua = true;
      };
    });
}
