{ ... }:
{
  # AST syntax highlighting
  plugins.treesitter = {
    enable = true;
    # TODO: figure out how to make this not open files pre-folded
    # fold based on AST
    # folding = true;

    # this is handled by orgmode plugin
    ignoreInstall = [ "org" ];
    # indent based on ast
    indent = true;
    # Lua highlighting for Nixvim Lua sections
    nixvimInjections = true;
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
}
