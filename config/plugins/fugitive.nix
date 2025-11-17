_: {
  config = {
    extraConfigLua = # lua
      ''
        vim.keymap.set('n', '<leader>g', function()
          -- Ensure :Git command is available
          if vim.fn.exists(':Git') > 0 then
            -- Call :Git command
            vim.cmd('Git')
            -- Only close other windows if no unsaved changes
            if vim.fn.winnr('$') > 1 then
              local ok = pcall(vim.cmd, 'only')
              if not ok then
                -- If only fails, just don't close other windows
                vim.notify('Cannot close windows with unsaved changes', vim.log.levels.WARN)
              end
            end
          else
            vim.notify('vim-fugitive is not loaded', vim.log.levels.ERROR)
          end
        end, { desc = "Git" })

        -- -- Automatically jump to unstaged section when fugitive-summary buffer is loaded
        -- vim.api.nvim_create_autocmd("User", {
        --   pattern = "FugitiveIndex",
        --   callback = function()
        --     vim.cmd("normal gu")
        --   end,
        --   desc = "Jump to unstaged section in fugitive"
        -- })
      '';

    # unstoppable git plugin
    # https://github.com/tpope/vim-fugitive/
    # https://nix-community.github.io/nixvim/plugins/fugitive
    plugins.fugitive = {
      enable = true;
    };
  };
}
