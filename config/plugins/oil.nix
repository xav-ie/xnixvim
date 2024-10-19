{ ... }:
{
  config = {
    # easily browse directories
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
