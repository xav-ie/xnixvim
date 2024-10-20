{ pkgs, ... }:
{
  # https://github.com/petertriho/nvim-scrollbar
  config = {
    extraPlugins = with pkgs.vimPlugins; [
      nvim-scrollview
    ];
    highlight = {
      ScrollView = {
        bg = "#333333";
      };
    };
  };
}
