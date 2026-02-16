{ pkgs, inputs, ... }:
let
  himalaya-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "himalaya-nvim";
    version = "unstable-2026-02-16";
    src = inputs.himalaya-nvim;
  };

in
{
  config = {
    extraPlugins = [ himalaya-nvim ];

    extraConfigLua = ''
      require('himalaya').setup({
        folder_picker = 'telescope',
        telescope_preview = false,
        flags = {
          header = '\xef\x80\xa4',
          -- flagged = '\xf3\xb0\x88\xbf',
          flagged = false,
          unseen = false,
          answered = '\xef\x84\x92',
          attachment = '\xef\x83\x86',
        },
        gutters = false,
        date_format = '%m/%d %H',
        thread_view = true,
        thread_reverse = true,
      })
    '';
  };
}
