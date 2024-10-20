{ pkgs, ... }:
let
  orgmode = pkgs.vimUtils.buildVimPlugin {
    name = "orgmode";
    src = pkgs.fetchFromGitHub {
      owner = "nvim-orgmode";
      repo = "orgmode";
      rev = "0.3.4";
      hash = "sha256-SmofuYt4fLhtl5qedYlmCRgOmZaw3nmlnMg0OMzyKnM=";
    };
  };
in
{
  # Actual orgmode in nvim
  # https://github.com/nvim-orgmode/orgmode
  config = {
    extraConfigLua = # lua
      ''
        require("orgmode").setup({
          org_agenda_files = '~/Notes/**/*',
          org_default_notes_file = '~/Notes/refile.org',
        })
      '';
    extraPlugins = [ orgmode ];
  };
}
