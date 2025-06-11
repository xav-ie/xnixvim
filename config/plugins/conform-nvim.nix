{
  config,
  lib,
  pkgs,
  ...
}:
{
  # https://github.com/stevearc/conform.nvim
  # https://nix-community.github.io/nixvim/plugins/conform-nvim
  config = {
    # auto-formatting
    plugins.conform-nvim = {
      enable = true;
      # strange SSL error fetching...?
      package = pkgs.vimPlugins.conform-nvim.overrideAttrs (_: {
        src = pkgs.fetchFromGitHub {
          owner = "stevearc";
          repo = "conform.nvim";
          rev = "9180320205d250429f0f80e073326c674e2a7149";
          sha256 = "128dby40rlzm6sy9ga0xbb9534rla1nc8k4apjsb8kyir40bgbi7";
          fetchSubmodules = true;
        };
      });
      lazyLoad.settings.event = "BufEnter";
      lazyLoad.enable = config.lazyLoad.enable;
      # Map of file-type to formatters
      settings = {
        formatters = {
          prettier = {
            command.__raw = ''
              require("conform.util").find_executable({
                -- Try to find in project
                "node_modules/.bin/prettier",
                -- Absolute as fallback
                "${lib.getExe pkgs.nodePackages.prettier}",
              }, "prettier")
            '';
            # Fixes issue of sub-git repos using greater git repo as root.
            cwd.__raw = ''
              require("conform.util").root_file({
                ".prettierrc",
                ".prettierrc.json",
                "package.json",
                ".git"
              })
            '';
          };
        };
        formatters_by_ft =
          let
            prettierFormat = [
              "prettier"
            ];
            shellFormat = [
              "shellcheck"
              "shellharden"
              "shfmt"
            ];
          in
          {
            astro = prettierFormat;
            bash = shellFormat;
            css = prettierFormat;
            graphql = prettierFormat;
            html = prettierFormat;
            javascript = prettierFormat;
            javascriptreact = prettierFormat;
            json = prettierFormat;
            jsonc = prettierFormat;
            less = prettierFormat;
            lua = [ "stylua" ];
            markdown = prettierFormat;
            mdx = prettierFormat;
            nix = [ "nixfmt" ];
            scss = prettierFormat;
            sh = shellFormat;
            typescript = prettierFormat;
            typescriptreact = prettierFormat;
            vue = prettierFormat;
            yaml = prettierFormat;
            # Use the "*" file-type to run formatters on all file-types.
            "*" = [ "trim_whitespace" ];
            # Use the "_" file-type to run formatters on file-types that don't
            # have other formatters configured.
            "_" = [
              "squeeze_blanks"
              "trim_whitespace"
              "trim_newlines"
            ];
          };
        format_on_save.__raw = # lua
          ''
            function(bufnr)
              if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
              end

              -- Disable for large files
              local max_filesize = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
              if ok and stats and stats.size > max_filesize then
                  return
              end

              return { timeout_ms = 1000, lsp_format = "fallback" }
            end
          '';
        notify_on_error = true;
        formatters = {
          shellcheck.command = lib.getExe pkgs.shellcheck;
          shfmt.command = lib.getExe pkgs.shfmt;
          shellharden.command = lib.getExe pkgs.shellharden;
          squeeze_blanks.command = lib.getExe' pkgs.coreutils "cat";
        };
      };
    };

    # TODO: is there a good way to abstract idea of toggling?
    extraConfigLua = # lua
      ''
        vim.api.nvim_create_user_command("ToggleFormat", function(args)
          if args.bang then
            -- ToggleFormat! will toggle formatting just for this buffer
            vim.b.disable_autoformat = not vim.b.disable_autoformat
            vim.notify("Buffer formatting: " .. tostring(not vim.b.disable_autoformat), vim.log.levels.INFO)
          else
            vim.g.disable_autoformat = not vim.g.disable_autoformat
            vim.notify("Global formatting: " .. tostring(not vim.g.disable_autoformat), vim.log.levels.INFO)
          end
        end, {
          desc = "Toggle autoformatting",
          bang = true,
        })
        vim.keymap.set('n', '<leader>tf', ":ToggleFormat<CR>", { desc = "Toggle formatting" })
        vim.keymap.set('n', '<leader>tF', ":ToggleFormat!<CR>", { desc = "Toggle formatting buffer" })
      '';
  };
}
