# TODO: not working :(
{
  inputs,
  pkgs,
  ...
}:
let
  cmp-luasnip-choice = pkgs.vimUtils.buildVimPlugin {
    name = "cmp_luasnip_choice";
    src = inputs.cmp-luasnip-choice;
    nvimRequireCheck = [ ];
    dependencies = with pkgs.vimPlugins; [
      nvim-cmp
      luasnip
    ];
  };
in
{
  config = {
    extraConfigLua = # lua
      ''
        require('cmp_luasnip_choice').setup({
          auto_open = true,
        })
      '';
    extraPlugins = [ cmp-luasnip-choice ];
  };
}
