{ ... }:
{
  # TODO: consider barbar.enable instead
  # tabs
  plugins.bufferline = {
    enable = true;
    settings = {
      options = {
        separatorStyle = "thin";
        showBufferCloseIcons = false;
        indicator.icon = "▌";
        tabSize = 0;
      };
    };
  };
}
