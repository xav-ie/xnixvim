{ lib, ... }:
let
  inherit (import ../modeKeys.nix { inherit lib; }) c nxo;
in
{
  # https://github.com/folke/flash.nvim/
  # https://nix-community.github.io/nixvim/plugins/flash
  config = {
    plugins.flash = {
      enable = true;
      # auto-jump when there is only one match
      settings.jump.autojump = true;
    };

    keymaps =
      lib.nixvim.keymaps.mkKeymaps { options.silent = true; } (c {
        "<C-s>" = {
          action.__raw = # lua
            ''function() require("flash").toggle() end'';
          options = {
            silent = true;
            desc = "Fla[<c-s>]h";
          };
        };
      })
      ++ (nxo {
        "s" = {
          options = {
            silent = true;
            desc = "Fla[s]h";
          };
          action.__raw = # lua
            ''function() require("flash").jump() end'';
        };
        "S" = {
          options = {
            silent = true;
            desc = "Flash Tree[S]itter";
          };
          action.__raw = # lua
            ''function() require("flash").treesitter() end'';
        };
        "<leader>sr" = {
          options = {
            silent = true;
            desc = "Fla[s]h [r]esume";
          };
          action.__raw = # lua
            ''
              function()
                require("flash").jump({continue = true})
              end
            '';
        };
        "<leader>sc" = {
          options = {
            silent = true;
            desc = "Fla[s]h [c]urrent word";
          };
          action.__raw = # lua
            ''
              function()
                require("flash").jump({
                  pattern = vim.fn.expand("<cword>"),
                })
              end
            '';
        };
        "<leader>sl" = {
          options = {
            silent = true;
            desc = "Fla[s]h [l]ine";
          };
          action.__raw = # lua
            ''
              function()
                require("flash").jump({
                  search = { mode = "search", max_length = 0 },
                  label = { after = { 0, 0 } },
                  pattern = "^"
                })
              end
            '';
        };
        "<leader>sw" = {
          options = {
            silent = true;
            desc = "Fla[s]h [w]ord";
          };
          action.__raw = # lua
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
        };
      });
  };
}
