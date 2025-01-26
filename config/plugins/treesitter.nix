{ config, pkgs, ... }:
{
  # beautiful, wonderful, good-enough syntax highlighting/AST parsing
  # https://github.com/nvim-treesitter/nvim-treesitter/
  # https://nix-community.github.io/nixvim/plugins/treesitter
  config = {
    # AST syntax highlighting
    plugins.treesitter = {
      enable = true;
      lazyLoad.settings.event = "BufEnter";
      lazyLoad.enable = config.lazyLoad.enable;
      # TODO: figure out how to make this not open files pre-folded
      # fold based on AST
      # folding = true;

      # Lua highlighting for Nixvim Lua sections
      nixvimInjections = true;

      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        arduino
        astro
        awk
        bash
        c
        cmake
        css
        csv
        diff
        elixir
        erlang
        git-config
        git-rebase
        gitattributes
        gitcommit
        gitignore
        gleam
        glsl
        go
        gomod
        gpg
        graphql
        haskell
        hcl
        hlsl
        html
        hyprlang
        ini
        java
        javascript
        jq
        jsdoc
        json
        jsonc
        kdl
        latex
        liquid
        llvm
        lua
        make
        markdown
        markdown-inline
        mermaid
        nickel
        nix
        org
        proto
        python
        regex
        rust
        scss
        sql
        ssh-config
        svelte
        swift
        toml
        tsv
        tsx
        typescript
        vim
        vimdoc
        vue
        wgsl
        xml
        yaml
        zig
      ];

      settings = {
        # auto install grammars on encounter
        auto_install = true;

        ensure_installed = [ ];
        # indent based on ast
        indent.enable = true;
        highlight.enable = true;
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
  };
}
