{ ... }:
{
  # AST syntax highlighting
  plugins.treesitter = {
    enable = true;
    # TODO: figure out how to make this not open files pre-folded
    # fold based on AST
    # folding = true;

    # Lua highlighting for Nixvim Lua sections
    nixvimInjections = true;

    settings = {
      # this is handled by orgmode plugin
      ignore_install = [ "org" ];
      # indent based on ast
      indent.enable = true;
      # this is SO useful 
      incremental_selection = {
        enable = true;
        keymaps = {
          init_selection = "<C-space>";
          node_decremental = "<bs>";
          node_incremental = "<C-space>";
          # IDK what this does
          scope_incremental = "grc";
        };
      };
    };
  };
}
