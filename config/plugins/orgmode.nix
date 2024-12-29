{ pkgs, inputs, ... }:
let
  orgmode = pkgs.vimUtils.buildVimPlugin {
    name = "orgmode";
    src = inputs.orgmode;
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
