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
            # prefer the node_module prettier
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
    formatOnSave = {
      timeoutMs = 500;
      lspFallback = true;
    };
  };
}
