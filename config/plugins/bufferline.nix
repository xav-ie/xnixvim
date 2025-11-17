{ config, ... }:
{
  config = {
    # TODO: consider barbar.enable instead
    # https://github.com/akinsho/bufferline.nvim
    # https://nix-community.github.io/nixvim/plugins/bufferline
    # tabs
    plugins.bufferline = {
      enable = true;
      lazyLoad.settings.event = "BufEnter";
      lazyLoad.enable = config.lazyLoad.enable;
      settings = {
        options = {
          separator_style = "thin";
          show_buffer_close_icons = false;
          indicator.icon = "▌";
          tab_size = 0;
          name_formatter = # lua
            ''
              function(buf)
                -- Rename fugitive buffers to "Git"
                if buf.path and buf.path:match("^fugitive://") then
                  return "Git"
                end
              end
            '';
          get_element_icon = {
            __raw = ''
              function(element)
                -- Use git icon for fugitive buffers
                if element.path and element.path:match("^fugitive://") then
                  return "󰊢", "DevIconGitConfig"
                end

                -- Default icon fetching for other buffers
                local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(element.filetype, { default = false })
                return icon, hl
              end
            '';
          };
          sort_by = {
            __raw = ''
              function(buffer_a, buffer_b)
                local modified_a = vim.fn.getftime(buffer_a.path)
                local modified_b = vim.fn.getftime(buffer_b.path)
                return modified_a > modified_b
              end
            '';
          };
          groups = {
            options = {
              toggle_hidden_on_enter = true;
            };
            items = [
              {
                __raw = ''
                  {
                    name = "Git",
                    priority = 1,
                    matcher = function(buf)
                      return buf.path:match("^fugitive://") ~= nil or buf.path:match("^%.git/") ~= nil
                    end,
                    separator = {
                      style = require("bufferline.groups").separator.none,
                    },
                  }
                '';
              }
              {
                __raw = "require('bufferline.groups').builtin.pinned";
              }
              {
                __raw = "require('bufferline.groups').builtin.ungrouped";
              }
            ];
          };
        };
      };
    };
  };
}
