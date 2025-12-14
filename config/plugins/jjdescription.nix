{ pkgs, ... }:
let
  jjdescription = pkgs.vimUtils.buildVimPlugin {
    name = "jjdescription";
    src = ../custom-plugins/jjdescription;
  };
in
{
  # Syntax highlighting for jjdescription files (Jujutsu VCS)
  # Uses gitcommit treesitter + custom matchadd for JJ: comments
  config = {
    extraConfigLua = # lua
      ''
        require('jjdescription').setup()
      '';
    extraPlugins = [ jjdescription ];
  };
}
