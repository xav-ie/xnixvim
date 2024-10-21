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
      rev = "07d20fce48a5629686aefb0a7cd4b25e33947d50";
      hash = "sha256-1z3WKIiikQqoweReUyK5O8MWSRN5y95qcxM6qzlKMME=";
    };
    # TODO: how to get curl?!?
    # nativeBuildInputs = [ pkgs.curl ];
    # buildInputs = [ pkgs.curl ];
    # extraPackages = [ pkgs.curl ];
    # ^ these dont't work
  };
in
{
  # AI auto-completion
  # https://github.com/supermaven-inc/supermaven-nvim
  config = {
    # TODO: which keymaps are best?
    # TODO: should I register this as a cmp source?
    extraConfigLua = # lua
      ''
        require("supermaven-nvim").setup({})
      '';
    extraPlugins = [ supermaven-nvim ];
    # extraPackages = [ pkgs.curl ];
    # ^ also doesn't work
  };
}
