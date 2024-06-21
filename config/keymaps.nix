{ helpers, lib, ... }:
{
  keymaps =
    # taken from https://github.com/traxys/nvim-flake/blob/c753bb1e624406ef454df9e8cb59d0996000dc93/config.nix#L94-L107
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
    in
    helpers.keymaps.mkKeymaps { options.silent = true; } (nm {
      "-" = "<cmd>Oil<CR>";
      "bp" = "<cmd>Telescope buffers<CR>";
      "<C-s>" = "<cmd>Telescope spell_suggest<CR>";
      "mk" = "<cmd>Telescope keymaps<CR>";
      "<leader>fu" = "<cmd>Telescope undo<CR>";
      # lsp navigation
      "gr" = "<cmd>Telescope lsp_references<CR>";
      "gI" = "<cmd>Telescope lsp_implementations<CR>";
      "gW" = "<cmd>Telescope lsp_workspace_symbols<CR>";
      "gF" = "<cmd>Telescope lsp_document_symbols<CR>";
      "ge" = "<cmd>Telescope diagnostics bufnr=0<CR>";
      "gE" = "<cmd>Telescope diagnostics<CR>";
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
      # "<leader>x" = ":bdelete <CR>";
    })
    ++ (vs {
      "<leader>/" = "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>";
      "<leader>?" = "<ESC><cmd>lua require('Comment.api').toggle.blockwise(vim.fn.visualmode())<CR>";
    })
    ++ (im {
      "<C-e>" = "<End>";
      "<C-b>" = "<ESC>^i";
      "<C-h>" = "<Left>";
      "<C-j>" = "<Down>";
      "<C-k>" = "<Up>";
      "<C-l>" = "<Right>";
    })
    ++ [
      {
        key = "<leader>/";
        mode = [ "n" ];
        action = # lua
          ''function() require("Comment.api").toggle.linewise.current() end'';
        lua = true;
        options.expr = true;
      }
      {
        key = "<leader>?";
        mode = [ "n" ];
        action = # lua
          ''function() require("Comment.api").toggle.blockwise.current() end'';
        lua = true;
        options.expr = true;
      }
      {
        key = "<leader>rn";
        mode = [ "n" ];
        action = # lua
          ''function() return ":IncRename " .. vim.fn.expand("<cword>") end'';
        lua = true;
        options.expr = true;
      }
      {
        key = "<leader>fm";
        mode = [ "n" ];
        action = # lua
          ''function() vim.lsp.buf.format { async = true } end'';
        lua = true;
        options = {
          desc = "LSP formatting";
          expr = true;
        };
      }
      {
        mode = [ "c" ];
        key = "<C-s>";
        options = {
          silent = true;
          desc = "Flash";
        };
        action = # lua
          ''function() require("flash").toggle() end'';
        lua = true;
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "s";
        options = {
          silent = true;
          desc = "Flash";
        };
        action = # lua
          ''function() require("flash").jump() end'';
        lua = true;
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "S";
        options = {
          silent = true;
          desc = "Flash treesitter";
        };
        action = # lua
          ''function() require("flash").treesitter() end'';
        lua = true;
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "<leader>sr";
        options = {
          silent = true;
          desc = "Flash resume";
        };
        action = # lua
          ''
            function()
              require("flash").jump({continue = true})
            end
          '';
        lua = true;
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "<leader>sc";
        options = {
          silent = true;
          desc = "Flash current word";
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
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "<leader>sl";
        options = {
          silent = true;
          desc = "Flash line";
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
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "<leader>sw";
        options = {
          silent = true;
          desc = "Flash word";
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
      }
    ];
}
