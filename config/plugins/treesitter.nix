{ config, pkgs, ... }:
let
  # Skip context headers for scopes shorter than
  # vim.g.treesitter_context_min_lines (default 5) — upstream has no such filter.
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
  config = {
    # Sticky context header at top of viewport while scrolling.
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

    plugins.treesitter = {
      enable = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
      lazyLoad.enable = config.lazyLoad.enable;
      # Folding is left to nvim-ufo (see nvim-ufo.nix), so `folding` stays off.

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
          # Skip oversized files to avoid parse/redraw stalls.
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
          indent = {
            enable = true;
            inherit disable;
          };
          # highlight.disable is a legacy option in nixvim's module; the
          # large-file guard is handled by the autocmd below instead.
          highlight = {
            enable = true;
          };
        };
    };

    extraConfigLua = # lua
      ''
        -- Large-file guard: stop highlighting on oversized buffers after
        -- tree-sitter's own FileType handler has attached.
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

        -- Incremental selection (<C-n> grows, <BS> shrinks), remapped onto
        -- Neovim 0.12's upstreamed node selection. Prefer the public
        -- vim.treesitter.select, fall back to the private _select module.
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

        -- Auto-install parsers for languages not in grammarPackages, then
        -- start highlighting. `available` memoizes get_available(); `pending`
        -- dedupes concurrent installs of the same lang.
        do
          local available
          local pending = {}
          local warned_toolchain = false

          vim.api.nvim_create_autocmd("FileType", {
            desc = "TS: install missing parser on demand, then highlight",
            callback = function(ev)
              local lang = vim.treesitter.language.get_lang(ev.match) or ev.match

              -- Already have queries: just make sure highlighting is on.
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
                    -- query.get is memoized and cached a nil above; clear it so
                    -- the freshly installed queries are seen.
                    pcall(function() vim.treesitter.query.get:clear() end)
                    -- Query presence, not `err`, is the real success signal.
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
