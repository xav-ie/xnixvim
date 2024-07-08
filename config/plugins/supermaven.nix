{ pkgs, ... }:
let
  # TODO: replace with local version
  # very fast and accurate auto-complete
  # https://github.com/supermaven-inc/supermaven-nvim
  supermaven-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "supermaven-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "supermaven-inc";
      repo = "supermaven-nvim";
      rev = "c7ab94a6bcde96c79ff51afd6a1494606bb6f10b";
      hash = "sha256-TeRWReHeEqP5I3tgfJdMDmHvL83NDCENRMcQrKbPiqg=";
    };
  };
in
{
  # TODO: which keymaps are best?
  # TODO: should I register this as a cmp source?
  extraConfigLua = # lua
    ''
      require("supermaven-nvim").setup({})
    '';
  extraPlugins = [ supermaven-nvim ];
}
