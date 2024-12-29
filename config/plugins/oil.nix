_:
{
  # easily browse directories
  # https://github.com/stevearc/oil.nvim/
  # https://nix-community.github.io/nixvim/plugins/oil
  config = {
    plugins.oil = {
      enable = true;
      settings = {
        view_options = {
          show_hidden = true;
        };
        win_options = {
          signcolumn = "yes:2";
        };
      };
    };
  };
}
