_: {
  config = {
    extraConfigLua = # lua
      ''
        vim.keymap.set('n', '<leader>g', function()
          -- Ensure :Git command is available
          if vim.fn.exists(':Git') > 0 then
            -- Call :Git command
            vim.cmd('Git | only!')
          else
            vim.notify('vim-fugitive is not loaded', vim.log.levels.ERROR)
          end
        end, { desc = "Git" })
      '';
    # unstoppable git plugin
    # https://github.com/tpope/vim-fugitive/
    # https://nix-community.github.io/nixvim/plugins/fugitive
    plugins.fugitive = {
      enable = true;
      # lazyLoad.enable = true;
      # TODO: not working... I think maybe only works for mkNeovimPlugin?
      # lazyLoad = {
      #   settings = {
      #     cmd = "Git";
      #     keys = [ "<leader>g" ];
      #     ft = "fugitive";
      #   };
      # };
    };
  };
}
