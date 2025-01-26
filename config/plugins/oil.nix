{ config, lib, ... }:
{
  # easily browse directories
  # https://github.com/stevearc/oil.nvim/
  # https://nix-community.github.io/nixvim/plugins/oil
  config = {
    plugins.oil = {
      enable = true;
      lazyLoad = {
        settings = {
          cmd = "Oil";
          keys = [
            "-"
          ];
          ft = "netrw";
        };
      };
      lazyLoad.enable = config.lazyLoad.enable;
      settings = {
        view_options = {
          show_hidden = true;
        };
        win_options = {
          signcolumn = "yes:2";
        };
      };
    };

    extraConfigLua =
      lib.mkIf config.plugins.oil.lazyLoad.enable
        # lua
        ''
          local function remove_oil_prefix(path)
            return vim.startswith(path, "oil://") and path:sub(7) or path
          end
          local function is_directory(path)
            return vim.fn.isdirectory(remove_oil_prefix(path)) == 1
          end

          -- Handle `nvim somedir`
          vim.api.nvim_create_autocmd("VimEnter", {
            callback = function(data)
              if is_directory(data.file) then
                vim.schedule(function()
                  require("oil").open(data.file)
                end)
              end
            end,
          })

          -- Handle `:e somedir/` and `gf somedir`
          vim.api.nvim_create_autocmd("BufEnter", {
            callback = function()
              local bufname = vim.api.nvim_buf_get_name(0)
              if is_directory(bufname) then
                require("lz.n").trigger_load("oil.nvim")
              end
            end,
          })
        '';
  };
}
