{ lib, ... }:
{
  # status line
  plugins.lualine = {
    enable = true;
    theme = lib.mkForce "powerline_dark";
    globalstatus = true;
    # idk if this does anything
    componentSeparators = {
      left = ""; # "";
      right = ""; # "";
    };
    sectionSeparators = {
      left = ""; # "";
      right = ""; # "";
    };

    # Available Sections:
    # A lot of these include reasonable extra logos/logic for display:
    # branch, buffers, diagnostics, diff, encoding, fileformat, 
    # filename, filesize, filetype, hostname, location, mode, 
    # progress, searchcount, selectioncount, tabs, windows
    # Raw things:
    # %t (filename), %c (column), %l (line), %p (percentage), %{any expression}
    sections = {
      lualine_a = [
        {
          name = "mode";
          fmt = "function(str) return str:sub(1,1) end";
        }
      ];
      lualine_b = [
        {
          name = "branch";
          icons_enabled = false;
        }
      ];
      lualine_c = [
        {
          name = "%{&readonly?&buftype=='help'?'📚 ':'🔒 ':''}%t"; # %{&modified?'*':''}
          color.__raw = "function() return vim.bo.modified and { fg = '#FFAA00' } or {} end";
          extraConfig.cond.__raw = "function() return vim.bo.filetype ~= 'oil' end";
        }
        # IDK why, but the extension does not seem to work properly
        {
          name = "";
          color.__raw = "function() return vim.bo.modified and { fg = '#FFAA00' } or {} end";
          fmt = # lua
            ''
              function()
                local ok, oil = pcall(require, 'oil')
                if ok then
                  return vim.fn.fnamemodify(oil.get_current_dir(), ':~')
                else
                  return ""
                end
              end
            '';
          extraConfig.cond.__raw = "function() return vim.bo.filetype == 'oil' end";
        }
      ];
      lualine_x = [
        "searchcount"
        "selectioncount"
        {
          name = "diff";
          # use gitsigns diff instead of manually recalculating it
          # https://github.com/nvim-lualine/lualine.nvim/wiki/Component-snippets
          extraConfig.source.__raw = # lua
            ''
              function() 
                local gitsigns = vim.b.gitsigns_status_dict
                  if gitsigns then
                    return {
                      added = gitsigns.added,
                      modified = gitsigns.changed,
                      removed = gitsigns.removed
                    }
                  end
              end
            '';
        }
        "diagnostics"
      ];
      lualine_y = [
        {
          name = "filetype";
          color = {
            bg = "Black"; # some icons are hard to see
          };
        }
      ];
      lualine_z = [
        {
          name = "";
          fmt = # lua
            ''
              function(str)
                local function progress()
                  local cur = vim.fn.line('.')
                  local total = vim.fn.line('$')
                  if cur == 1 then
                    return ' 0'
                  elseif cur == total then
                    return '00'
                  else
                    return string.format('%2d', math.floor(cur / total * 100))
                  end
                end
                return ('%2c:' .. progress())
              end
            '';
        }
      ];
    };

    # what sections to show in inactive windows
    # N/A because I disabled it on other sub-windows
    # inactiveSections = { };
  };
}
