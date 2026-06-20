{ config, pkgs, ... }:
let
  # Upstream treesitter-context has no per-node filter — every node matched
  # by a language's context queries shows up, including tiny scopes like a
  # 2-line object property. Patch context_range() to short-circuit (return
  # nil) for candidates whose body spans fewer lines than the threshold,
  # set via vim.g.treesitter_context_min_lines (default 5).
  treesitter-context-patched = pkgs.vimPlugins.nvim-treesitter-context.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace lua/treesitter-context/context.lua \
        --replace-fail 'local range = { node:range() } --- @type Range4
        range[3] = range[1] + 1' 'local range = { node:range() } --- @type Range4
        if (range[3] - range[1]) < (vim.g.treesitter_context_min_lines or 5) then
          return nil
        end
        range[3] = range[1] + 1'
    '';
  });
in
{
  # beautiful, wonderful, good-enough syntax highlighting/AST parsing
  # https://github.com/nvim-treesitter/nvim-treesitter/
  # https://nix-community.github.io/nixvim/plugins/treesitter
  config = {
    # Sticky context header at top of viewport while scrolling.
    # https://github.com/nvim-treesitter/nvim-treesitter-context
    # https://nix-community.github.io/nixvim/plugins/treesitter-context
    plugins.treesitter-context = {
      enable = true;
      package = treesitter-context-patched;
      lazyLoad.enable = config.lazyLoad.enable;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
      settings = {
        max_lines = 3;
        min_window_height = 20;
        multiline_threshold = 1;
        trim_scope = "outer";
      };
    };

    # AST syntax highlighting
    plugins.treesitter = {
      enable = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
      lazyLoad.enable = config.lazyLoad.enable;
      # Folding is handled by nvim-ufo (see nvim-ufo.nix), which uses
      # treesitter as a fold provider but with foldlevel=99 so files open
      # unfolded. Treesitter's own `folding` stays off to avoid double folding.
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
        # org
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

      settings =
        let
          # fix large file crash
          disable.__raw = ''
            function(_, buf)
              local max_filesize = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                return true
              end
            end
          '';
        in
        {
          # indent based on ast
          indent = {
            enable = true;
            inherit disable;
          };
          # `disable` is intentionally omitted here: nixvim's modern treesitter
          # module flags `settings.highlight.disable` as a legacy option (and
          # its native replacement only takes a language list, not a size-based
          # function). Large-file highlighting is guarded by the autocmd below
          # instead. indent/incremental_selection keep the function — they are
          # not flagged.
          highlight = {
            enable = true;
          };
        };
    };

    # Large-file highlight guard. Replaces the old `highlight.disable` size
    # callback: tree-sitter attaches via core `vim.treesitter.start`, so once
    # it has, we stop it for oversized buffers to avoid parse/redraw stalls.
    # Scheduled so it runs after tree-sitter's own FileType handler.
    extraConfigLua = # lua
      ''
        do
          local max_filesize = 100 * 1024 -- 100 KB
          vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
              if ok and stats and stats.size > max_filesize then
                vim.schedule(function()
                  if vim.api.nvim_buf_is_valid(args.buf) then
                    pcall(vim.treesitter.stop, args.buf)
                  end
                end)
              end
            end,
            desc = "Disable tree-sitter highlighting on large files",
          })
        end

        -- Incremental selection. nvim-treesitter's `main` rewrite dropped its
        -- incremental_selection module; the feature was upstreamed into Neovim
        -- 0.12 (default visual maps an/in/]n/[n). Remap to the old <C-n>/<bs>
        -- flow: <C-n> starts then grows the selection, <bs> shrinks it.
        -- 0.12.x exposes the private vim.treesitter._select module; newer Nvim
        -- promotes it to public vim.treesitter.select(dir, count) — prefer the
        -- public API and fall back to the private one.
        do
          local has_parser = function()
            return vim.treesitter.get_parser(nil, nil, { error = false }) ~= nil
          end
          local grow = function()
            if vim.treesitter.select then
              vim.treesitter.select("parent", vim.v.count1)
            else
              require("vim.treesitter._select").select_parent(vim.v.count1)
            end
          end
          local shrink = function()
            if vim.treesitter.select then
              vim.treesitter.select("child", vim.v.count1)
            else
              require("vim.treesitter._select").select_child(vim.v.count1)
            end
          end
          vim.keymap.set("n", "<C-n>", function()
            if not has_parser() then return end
            vim.cmd.normal({ "v", bang = true })
            grow()
          end, { desc = "TS: start/grow node selection" })
          vim.keymap.set("x", "<C-n>", function()
            if has_parser() then grow() end
          end, { desc = "TS: grow node selection" })
          vim.keymap.set("x", "<BS>", function()
            if has_parser() then shrink() end
          end, { desc = "TS: shrink node selection" })
        end

        -- On-demand install for languages not in grammarPackages: installs via
        -- require("nvim-treesitter").install() into stdpath("data")/site at runtime.
        do
          -- available: memoizes the costly get_available(). pending: dedupes
          -- concurrent installs of a lang to one notify/install.
          local available
          local pending = {}
          local warned_toolchain = false

          vim.api.nvim_create_autocmd("FileType", {
            desc = "TS: install missing parser on demand, then highlight",
            callback = function(ev)
              local lang = vim.treesitter.language.get_lang(ev.match) or ev.match

              -- Queries present: just ensure highlighting is on. nixvim's own
              -- autocmd covers grammarPackages langs, not runtime-installed ones.
              if vim.treesitter.query.get(lang, "highlights") then
                if not vim.treesitter.highlighter.active[ev.buf] then
                  pcall(vim.treesitter.start, ev.buf, lang)
                end
                return
              end

              -- Defer so lz-n has loaded nvim-treesitter (lazy on BufReadPost).
              vim.schedule(function()
                local ok, ts = pcall(require, "nvim-treesitter")
                if not ok then return end

                available = available or ts.get_available()
                if not vim.tbl_contains(available, lang) then return end
                if pending[lang] then return end

                -- Missing CLI/compiler makes install hang silently (#7873).
                if vim.fn.executable("tree-sitter") == 0 or vim.fn.executable("cc") == 0 then
                  if not warned_toolchain then
                    warned_toolchain = true
                    vim.notify(
                      "Cannot install tree-sitter parsers: `tree-sitter` CLI or `cc` not on PATH.",
                      vim.log.levels.WARN, { title = "nvim-treesitter" })
                  end
                  return
                end

                pending[lang] = true
                vim.notify("Installing tree-sitter parser: " .. lang,
                  vim.log.levels.INFO, { title = "nvim-treesitter" })
                ts.install({ lang }, { summary = false }):await(function(err)
                  vim.schedule(function()
                    pending[lang] = nil
                    -- query.get cached nil before install; Neovim only clears that
                    -- cache on an rtp change, so self-assign to force it.
                    vim.o.runtimepath = vim.o.runtimepath
                    -- Query presence is the real success signal — install() reports
                    -- a failed build by return value, not via `err`.
                    if not vim.treesitter.query.get(lang, "highlights") then
                      vim.notify(
                        "Failed to install tree-sitter parser: " .. lang
                          .. (err and (" (" .. tostring(err) .. ")") or ""),
                        vim.log.levels.WARN, { title = "nvim-treesitter" })
                      return
                    end
                    -- Buffer may have been deleted or changed filetype during install.
                    if vim.api.nvim_buf_is_valid(ev.buf)
                       and vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype) == lang then
                      pcall(vim.treesitter.start, ev.buf, lang)
                    end
                  end)
                end)
              end)
            end,
          })
        end
      '';
  };
}
