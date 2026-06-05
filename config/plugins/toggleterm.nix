{ config, ... }:
{
  # VSCode-style toggleable terminal panel
  # https://github.com/akinsho/toggleterm.nvim/
  # https://nix-community.github.io/nixvim/plugins/toggleterm
  config = {
    plugins.toggleterm = {
      enable = true;
      lazyLoad.enable = config.lazyLoad.enable;
      lazyLoad.settings = {
        cmd = [
          "ToggleTerm"
          "ToggleTermToggleAll"
        ];
        keys = [
          {
            __unkeyed-1 = "<leader>tt";
            __unkeyed-2 = "<cmd>ToggleTerm direction=horizontal<CR>";
            mode = "n";
            desc = "[t]oggle [t]erminal";
          }
        ];
      };
      settings = {
        # Size scales with the window so it always feels like ~the bottom 30%.
        size.__raw = # lua
          ''
            function(term)
              if term.direction == "horizontal" then
                return math.floor(vim.o.lines * 0.3)
              elseif term.direction == "vertical" then
                return math.floor(vim.o.columns * 0.4)
              end
            end
          '';
        direction = "horizontal";
        shell = "nu";
        start_in_insert = true;
        persist_size = true;
        persist_mode = true;
        # Use the editor's own background so it blends like the VSCode panel.
        shade_terminals = false;
      };
    };
  };
}
