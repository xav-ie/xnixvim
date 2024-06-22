{ pkgs, ... }:
{
  # auto-formatting
  plugins.conform-nvim = {
    enable = true;
    # Map of file-type to formatters
    formattersByFt =
      let
        prettierFormat = [
          [
            # prefer node_modules/.bin/prettier
            "prettier"
            # fallback to global prettier
            "${pkgs.nodePackages.prettier}/bin/prettier"
          ]
        ];
      in
      {
        lua = [ "stylua" ];
        html = prettierFormat;
        markdown = prettierFormat;
        javascript = prettierFormat;
        javascriptreact = prettierFormat;
        json = prettierFormat;
        jsonc = prettierFormat;
        typescript = prettierFormat;
        typescriptreact = prettierFormat;
        nix = [ "nixfmt" ];
        # Use the "*" file-type to run formatters on all file-types.
        #"*" = [ "codespell" ];
        # Use the "_" file-type to run formatters on file-types that don't
        # have other formatters configured.
        "_" = [ "trim_whitespace" ];
      };

    extraOptions = {
      format_on_save.__raw = # lua
        ''
          function(bufnr)
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
              return
            end
            return { timeout_ms = 500, lsp_format = "fallback" }
          end
        '';
    };
    notifyOnError = true;
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
}
