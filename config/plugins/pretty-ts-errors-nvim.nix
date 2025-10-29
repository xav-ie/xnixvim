{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  # Build the CLI tool from npm
  pretty-ts-errors-markdown = pkgs.buildNpmPackage {
    pname = "pretty-ts-errors-markdown";
    version = "0.0.15";

    src = pkgs.fetchFromGitHub {
      owner = "hexh250786313";
      repo = "pretty-ts-errors-markdown";
      rev = "0.0.15";
      hash = "sha256-zxp8YAfF15sE8EZmO3IFB7PmJAw9GfGhGlJQs0qliz4=";
    };

    npmDepsHash = "sha256-aC+t2FYWJgDzXmfYg2IDJ7W2pLPAZ1o3TC68MWZhbSg=";

    postBuild = ''
      # The build script outputs to node_modules/.esbuild-cache/lib
      # but the package expects files in lib/
      cp -r node_modules/.esbuild-cache/lib .
    '';

    meta = {
      description = "A fork of pretty-ts-errors that outputs markdown";
      homepage = "https://github.com/hexh250786313/pretty-ts-errors-markdown";
    };
  };

  # Build the Neovim plugin
  pretty-ts-errors-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "pretty-ts-errors.nvim";
    src = inputs.pretty-ts-errors-nvim;
    dependencies = with pkgs.vimPlugins; [ plenary-nvim ];
  };

  cfg = config.programs.pretty-ts-errors;
in
{
  # TypeScript error formatting
  # https://github.com/youyoumu/pretty-ts-errors.nvim
  options.programs.pretty-ts-errors = {
    enable = lib.mkEnableOption "pretty-ts-errors";
  };

  config = lib.mkMerge [
    # Enable by default
    { programs.pretty-ts-errors.enable = lib.mkDefault true; }

    # Plugin configuration (when enabled)
    (lib.mkIf cfg.enable {
      extraConfigLua = ''
        require('pretty-ts-errors').setup({
          executable = "${pretty-ts-errors-markdown}/bin/pretty-ts-errors-markdown",
          float_opts = {
            border = "rounded",
            max_width = 80,
            max_height = 20,
            wrap = false,
          },
          auto_open = false,
          lazy_window = false,
        })

        -- Helper function to close diagnostic floating windows
        local function close_diagnostic_floats()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local config = vim.api.nvim_win_get_config(win)
            if config.relative ~= "" then
              local buf = vim.api.nvim_win_get_buf(win)
              local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
              -- Close diagnostic floats (but not notify or scrollview)
              if ft == "" or ft == "markdown" then
                -- Check if it's a diagnostic float by checking the buffer name
                local bufname = vim.api.nvim_buf_get_name(buf)
                if bufname == "" or bufname:match("diagnostic") then
                  pcall(vim.api.nvim_win_close, win, true)
                end
              end
            end
          end
        end

        -- Store the helper function globally for use in keymaps
        _G.close_diagnostic_floats = close_diagnostic_floats
      '';

      extraPlugins = [ pretty-ts-errors-nvim ];

      # Add keymaps for the plugin
      keymaps = [
        {
          key = "<leader>te";
          action.__raw = ''
            function()
              _G.close_diagnostic_floats()
              require('pretty-ts-errors').show_formatted_error()
            end
          '';
          mode = "n";
          options = {
            silent = true;
            desc = "Show [t]ypescript [e]rror";
          };
        }
        {
          key = "<leader>tE";
          action.__raw = ''
            function()
              _G.close_diagnostic_floats()
              require('pretty-ts-errors').open_all_errors()
            end
          '';
          mode = "n";
          options = {
            silent = true;
            desc = "Show all [t]ypescript [E]rrors";
          };
        }
      ];
    })
  ];
}
