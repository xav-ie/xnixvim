{ pkgs, ... }:
{
  # status line
  # https://github.com/nvim-lualine/lualine.nvim/
  # https://nix-community.github.io/nixvim/plugins/lualine
  config = {
    # Hide statusline until lualine loads to prevent blue flash
    # https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/ui.lua
    extraConfigLuaPre = ''
      vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE", fg = "NONE" })
      vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE", fg = "NONE" })
      vim.o.statusline = " "
      vim.o.laststatus = 0
    '';
    plugins.lualine = {
      enable = true;

      # Upstream drives redraws from four repeating libuv timers that never
      # stop, so an idle or unfocused nvim keeps waking the event loop. The
      # patch makes lualine fully event-driven:
      #   - the redraw queue is flushed by a one-shot `vim.schedule` armed on
      #     demand, instead of the periodic `refresh_time` tick
      #   - a 0 interval for statusline/tabline/winbar arms no timer at all
      # Redraws land on the next event-loop iteration, which is sooner than
      # any tick, so this is also more responsive than the stock 16ms default.
      package = pkgs.vimPlugins.lualine-nvim.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./lualine-event-driven.patch ];
      });

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
          theme = "auto";

          # Upstream runs a periodic redraw for each of statusline, tabline and
          # winbar (default 1000ms each) on top of the refresh_time tick, all
          # of which keep firing while nvim is idle or unfocused.
          #
          # Every section below derives from state that fires an autocmd, so
          # nothing needs polling. The patch above treats a 0 interval as
          # "event-driven only" and arms no timer; the event list is widened to
          # cover the sections upstream's defaults miss.
          refresh = {
            # 0 = no periodic timer; redraws come only from the events below.
            statusline = 0;
            tabline = 0;
            winbar = 0;
            events = [
              # upstream defaults
              "WinEnter"
              "BufEnter"
              "BufWritePost"
              "SessionLoadPost"
              "FileChangedShellPost"
              "VimResized"
              "Filetype"
              "CursorMoved"
              "CursorMovedI"
              "ModeChanged"
              # added: sections above that the defaults do not cover
              "DirChanged" # lualine_c cwd component
              "TextChanged" # modified flag (fg = #FFAA00)
              "TextChangedI"
              "DiagnosticChanged" # lualine_x diagnostics
              # gitsigns publishes diff/head updates as `User GitSignsUpdate`.
              # lualine registers its autocmd with pattern `*`, so this matches
              # every User event; each one only sets a queued flag that the
              # scheduled flush coalesces, so the cost is negligible.
              "User"
            ];
          };
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
                      local dirname = vim.fn.fnamemodify(oil.get_current_dir() or vim.fn.getcwd(), ":~")
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
                  function()
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
