_: {
  config = {
    extraConfigLua = # lua
      ''
        vim.keymap.set('n', '<leader>g', function()
          if vim.fn.exists(':Git') > 0 then -- Ensure :Git command is available
            vim.cmd('Git')                  -- Call :Git command
          else
            vim.notify('vim-fugitive is not loaded', vim.log.levels.ERROR)
          end
        end, { desc = "Git" })
      '';
    # unstoppable git plugin
    # https://github.com/tpope/vim-fugitive/
    # https://nix-community.github.io/nixvim/plugins/fugitive
    plugins.fugitive.enable = true;
  };
}
