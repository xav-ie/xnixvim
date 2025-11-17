{ helpers, ... }:
{
  config = {
    # https://github.com/smjonas/inc-rename.nvim
    # https://nix-community.github.io/nixvim/plugins/inc-rename
    plugins.inc-rename = {
      enable = true;
    };

    # Disable noice floating input for inc-rename to prevent overlap at top of file
    plugins.noice.settings.presets.inc_rename = false;

    keymaps = helpers.keymaps.mkKeymaps { } [
      {
        mode = "n";
        key = "<leader>ln";
        action.__raw = # lua
          ''function() return ":IncRename " .. vim.fn.expand("<cword>") end'';
        options = {
          expr = true;
          desc = "LSP Re[n]ame";
        };
      }
    ];
  };
}
