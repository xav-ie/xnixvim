{ ... }:
{
  config = {
    # https://github.com/smjonas/inc-rename.nvim
    # https://nix-community.github.io/nixvim/plugins/inc-rename
    plugins.inc-rename = {
      enable = true;
      cmdName = "IncRename"; # This is the default, but making it explicit
    };

    # Disable noice floating input for inc-rename to prevent overlap at top of file
    plugins.noice.settings.presets.inc_rename = false;

    extraConfigLua = # lua
      ''
        vim.keymap.set('n', '<leader>ln', function()
          return ":IncRename " .. vim.fn.expand("<cword>")
        end, { expr = true, desc = "LSP Re[n]ame" })
      '';
  };
}
