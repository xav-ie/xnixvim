{ pkgs, ... }:
let
  vim-AdvancedSorters = pkgs.vimUtils.buildVimPlugin {
    name = "vim-AdvancedSorters";
    src = pkgs.fetchFromGitHub {
      owner = "inkarkat";
      repo = "vim-AdvancedSorters";
      rev = "f6d29af8a2291895973bf98c2630cc68a8115068";
      hash = "sha256-rpkWT6g9LNWp5Sv5sp2rYV16v8ZTWaNYh+NzvXnF4CY=";
    };
  };
in
{
  extraPlugins = [ vim-AdvancedSorters ];
}
