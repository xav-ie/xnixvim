{ config, ... }:
{
  config = {
    # Improved UI and workflow for the quickfix list (editable buffer,
    # context expansion, better highlighting).
    # https://github.com/stevearc/quicker.nvim
    # https://nix-community.github.io/nixvim/plugins/quicker
    plugins.quicker = {
      enable = true;
      lazyLoad.enable = config.lazyLoad.enable;
      lazyLoad.settings = {
        ft = "qf";
        keys = [
          "<leader>q"
          "<leader>Q"
        ];
      };
      settings = {
        keys = [
          {
            __unkeyed-1 = ">";
            __unkeyed-2.__raw = ''
              function()
                require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
              end
            '';
            desc = "Expand quickfix context";
          }
          {
            __unkeyed-1 = "<";
            __unkeyed-2.__raw = "require('quicker').collapse";
            desc = "Collapse quickfix context";
          }
        ];
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>q";
        action.__raw = "function() require('quicker').toggle() end";
        options.desc = "Toggle [q]uickfix";
      }
      {
        mode = "n";
        key = "<leader>Q";
        action.__raw = "function() require('quicker').toggle({ loclist = true }) end";
        options.desc = "Toggle loclist";
      }
    ];
  };
}
