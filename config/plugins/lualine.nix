{ lib, ... }:
{
  config = {
    # status line
    plugins.lualine = {
      enable = true;
      settings = {
        options = {
          # idk if this does anything
          component_separators = {
            left = ""; # "";
            right = ""; # "";
          };
          section_separators = {
            left = ""; # "";
            right = ""; # "";
          };
          globalstatus = true;
          theme = lib.mkForce "powerline_dark";
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
              __unkeyed-1 = "mode";
              fmt.__raw = "function(str) return str:sub(1,1) end";
            }
          ];
          lualine_b = [
            {
              __unkeyed-1 = "branch";
              icons_enabled = false;
            }
          ];
          lualine_c = [
            # TODO: replace with possession, scope, or tabufline nvim...
            {
              __unkeyed-1 = "";
              fmt.__raw = # lua
                ''
                  function()
                    -- global cwd ~ cd
                    local cwd = vim.fn.getcwd()
                    -- tab local cwd ~ tc[d]
                    local tcwd = vim.fn.getcwd(-1)
                    -- window local cwd ~ cw[d]
                    local wcwd = vim.fn.getcwd(-1, -1)
                    -- TODO: fix logic...
                    return vim.fn.fnamemodify(tcwd, ':~') 
                    -- if wcwd ~= tcwd then
                    --   return wcwd
                    -- elseif tcwd ~= cwd then
                    --   return tcwd
                    -- else
                    --   return cwd
                    -- end
                  end
                '';
            }
            {

              __unkeyed-1 = "%{&readonly?&buftype=='help'?'📚 ':'🔒 ':''}%t"; # %{&modified?'*':''}
              color.__raw = "function() return vim.bo.modified and { fg = '#FFAA00' } or {} end";
              cond.__raw = "function() return vim.bo.filetype ~= 'oil' end";
            }
            # # IDK why, but the extension does not seem to work properly
            {
              __unkeyed-1 = "";
              color.__raw = "function() return vim.bo.modified and { fg = '#FFAA00' } or {} end";
              fmt.__raw = # lua
                ''
                  function()
                    local ok, oil = pcall(require, 'oil')
                    if ok then
                      local dirname = vim.fn.fnamemodify(oil.get_current_dir(), ':~')
                      local entry = oil.get_cursor_entry()
                      if not entry then
                        return dirname
                      else
                        return dirname .. entry.name
                      end
                    else
                      return "Could not load oil"
                    end
                  end
                '';
              cond.__raw = "function() return vim.bo.filetype == 'oil' end";
            }
          ];
          lualine_x = [
            "searchcount"
            "selectioncount"
            {
              __unkeyed-1 = "diff";
              # use gitsigns diff instead of manually recalculating it
              # https://github.com/nvim-lualine/lualine.nvim/wiki/Component-snippets
              source.__raw = # lua
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
              __unkeyed-1 = "filetype";
              color = {
                bg = "Black"; # some icons are hard to see
              };
            }
          ];
          lualine_z = [
            {
              __unkeyed-1 = "";
              fmt.__raw = # lua
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

      };

      # what sections to show in inactive windows
      # N/A because I disabled it on other sub-windows
      # inactiveSections = { };
    };
  };
}
