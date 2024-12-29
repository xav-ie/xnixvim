_: {
  # vim in the browser
  # https://github.com/glacambre/firenvim/
  # https://nix-community.github.io/nixvim/plugins/firenvim
  config = {
    plugins.firenvim = {
      enable = true;
      settings = {
        localSettings = {
          # allow sites you want to takeover here
          "https?://(github\.com|mail\.proton\.me)/.*" = {
            priority = 0;
            takeover = "always";
          };
          "https?://.*\..*/.*" = {
            priority = 1;
            takeover = "never";
          };
        };
      };
      luaConfig.post = # lua
        ''
          if vim.g.started_by_firenvim == true then
            vim.o.guifont = "Maple Mono NF:h18"
          end
          vim.api.nvim_create_autocmd({'BufEnter'}, {
              pattern = "github.com_*.txt",
              command = "set filetype=markdown"
          })
        '';
    };
  };
}
