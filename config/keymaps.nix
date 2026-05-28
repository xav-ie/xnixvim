# https://github.com/traxys/nvim-flake/blob/c753bb1e624406ef454df9e8cb59d0996000dc93/config.nix#L94-L107
{
  config,
  lib,
  ...
}:
let
  modeKeys = import ./modeKeys.nix { inherit lib; };
  bufferLineEnabled = config.plugins.bufferline.enable;
in
{
  config = {
    keymaps =
      lib.nixvim.keymaps.mkKeymaps { options.silent = true; } (
        modeKeys.nm {
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
          "<tab>" = if bufferLineEnabled then ":BufferLineCycleNext <CR>" else ":bnext <CR>";
          "<S-tab>" = if bufferLineEnabled then ":BufferLineCyclePrev <CR>" else ":bprevious <CR>";
          # located in ./plugins/tabscope.nix
          # "<leader>x" = ":bdelete <CR>";
        }
      )
      ++ (modeKeys.vs {
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
      ++ (modeKeys.im {
        "<C-e>" = "<End>";
        "<C-b>" = "<ESC>^i";
        "<C-h>" = "<Left>";
        "<C-j>" = "<Down>";
        "<C-k>" = "<Up>";
        "<C-l>" = "<Right>";
      })
      ++ (modeKeys.t {
        "<esc><esc>" = {
          options = {
            silent = true;
            desc = "Enter normal mode";
          };
          action = "<c-\\><c-n>";
        };
      });
  };
}
