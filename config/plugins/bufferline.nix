{ ... }:
{
  # TODO: consider barbar.enable instead
  # tabs
  plugins.bufferline = {
    enable = true;
    settings = {
      options = {
        separator_style = "thin";
        showBuffer_close_icons = false;
        indicator.icon = "▌";
        tab_size = 0;
      };
    };
  };
}
