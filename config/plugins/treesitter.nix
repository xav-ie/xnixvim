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
      incrementalSelection = {
        enable = true;
        keymaps = {
          initSelection = "<C-space>";
          nodeDecremental = "<bs>";
          nodeIncremental = "<C-space>";
          # IDK what this does
          scopeIncremental = "grc";
        };
      };
    };
  };
}
