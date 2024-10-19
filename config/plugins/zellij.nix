{ ... }:
{
  config = {
    plugins.zellij = {
      enable = true;

      settings = {
        debug = true;
        vimTmuxNavigatorKeybinds = true;
        whichKeyEnabled = true;
        replaceVimWindowNavigationKeybinds = true;
      };
    };
  };
}
