_: {
  # Lightweight markdown prettification, in place of markview's full renderer.
  #
  # Two mechanisms, because neither covers the whole job:
  #
  #   queries/markdown/highlights.scm
  #     Tree-sitter conceal. Substitutes a single glyph for a node, so it
  #     handles bullets and blockquote bars. Runs inside the highlighter that
  #     is already parsing the buffer, so it costs effectively nothing and
  #     only touches visible lines.
  #
  #   plugin/markdown-decor.lua
  #     A decoration provider, for the things conceal structurally cannot do:
  #     a rule that spans the window (conceal gives one glyph, not a repeat)
  #     and a heading background that extends past the heading text to the
  #     end of the line.
  #
  # Both are viewport-scoped, so unlike markview the cost does not grow with
  # document length. Measured on a 4224-line changelog, open time went from
  # ~440ms with markview to ~49ms with this.
  config = {
    extraFiles = {
      "queries/markdown/highlights.scm".text = ''
        ;; extends

        ; ---------------------------------------------------------------------
        ; Markdown conceal overrides.
        ;
        ; The `;; extends` header above is required. Without it this file
        ; REPLACES Neovim's built-in markdown queries rather than adding to
        ; them, and you lose everything in the list below.
        ;
        ; Already concealed by Neovim's own queries -- nothing to do here:
        ;   **bold**  *italic*  _underscore_   -> markers hidden
        ;   `inline code`                      -> backticks hidden
        ;   ```lang fence lines                -> whole line hidden
        ;   [text](url)                        -> shows just `text`
        ;   &amp; &lt; &gt;                    -> shown as & < >
        ;
        ; conceallevel=2 is set per markdown buffer in plugins/obsidian.nix.
        ; concealcursor is left empty, so the line the cursor is on shows raw
        ; markup while every other line stays concealed.
        ;
        ; Finding node names:  :InspectTree   (move cursor around)
        ; Captures at cursor:  :Inspect
        ; ---------------------------------------------------------------------


        ; --- list bullets ----------------------------------------------------
        ; Neovim ships this commented out, noting the parser can include a
        ; trailing space in the marker node; #offset! trims it.
        ([(list_marker_plus) (list_marker_star) (list_marker_minus)]
          @markup.list
          (#offset! @markup.list 0 0 0 -1)
          (#set! conceal "•"))


        ; --- block quote marker ----------------------------------------------
        ; The `>` opening a quote and the `>` continuing it are different
        ; nodes. Conceal both so a multi-line quote gets an unbroken bar.
        ((block_quote_marker) @punctuation.special (#set! conceal "▋"))

        ((block_continuation) @punctuation.special
          (#lua-match? @punctuation.special "^%s*>")
          (#set! conceal "▋"))


        ; --- headings --------------------------------------------------------
        ; The background is drawn in plugin/markdown-decor.lua. Uncomment here
        ; to also replace the `#` markers with icons.
        ;
        ; ((atx_h1_marker) @markup.heading.1 (#set! conceal "󰉫"))
        ; ((atx_h2_marker) @markup.heading.2 (#set! conceal "󰉬"))
        ; ((atx_h3_marker) @markup.heading.3 (#set! conceal "󰉭"))
        ; ((atx_h4_marker) @markup.heading.4 (#set! conceal "󰉮"))
        ; ((atx_h5_marker) @markup.heading.5 (#set! conceal "󰉯"))
        ; ((atx_h6_marker) @markup.heading.6 (#set! conceal "󰉰"))


        ; --- task list checkboxes --------------------------------------------
        ; ((task_list_marker_checked)   @markup.list.checked   (#set! conceal "󰗠"))
        ; ((task_list_marker_unchecked) @markup.list.unchecked (#set! conceal "󰄰"))


        ; --- horizontal rule -------------------------------------------------
        ; NOT here. Conceal substitutes one glyph for the whole node, so `---`
        ; would become a single `─`. The full-width rule is drawn in
        ; plugin/markdown-decor.lua.
      '';

      "plugin/markdown-decor.lua".text = ''
        -- Markdown decorations that conceal queries cannot express.
        --
        -- Conceal substitutes a single glyph for a whole node, so it can turn
        -- `**` into nothing or `>` into `▋`, but it cannot repeat a character
        -- across the window or paint a background past the end of a heading's
        -- text. Those need extmarks, which is what this file does.
        --
        -- It runs as a decoration provider, so Neovim calls it per redraw with
        -- only the lines actually on screen. Cost does not grow with document
        -- size -- the thing that made markview slow on large files.
        --
        -- Lines are classified with tree-sitter rather than a pattern match,
        -- so `# x` inside a fenced code block is correctly not a heading.

        local M = {}

        -- -------------------------------------------------------------------
        -- Config
        -- -------------------------------------------------------------------

        -- Which heading levels get a background.
        M.heading_levels = { 1, 2, 3, 4, 5, 6 }

        -- Background for heading lines.
        --
        -- nil means "use whatever MarkviewHeading1 is set to", which is how
        -- this looked before markview was turned off. That group is defined by
        -- the xdusk colorscheme (p.bg_header = "#200030"), not by markview, so
        -- it resolves whether or not markview is loaded -- and it keeps the
        -- colour living in the xdusk flake with the rest of the palette
        -- instead of being duplicated here.
        --
        -- Set to a hex string to override.
        M.heading_bg = nil
        M.heading_bg_fallback = "#200030"

        -- Character the section break is drawn with, and its colour.
        M.rule_char = "─"
        M.rule_fg = "#5b5470"

        -- Inherit each heading's foreground from the tree-sitter highlight so
        -- the levels keep their distinct colours. Set false to leave fg alone.
        M.heading_keep_fg = true

        -- -------------------------------------------------------------------

        local ns = vim.api.nvim_create_namespace("markdown_decor")

        -- Resolve the heading background once per colorscheme load.
        local function resolve_heading_bg()
          if M.heading_bg then
            return M.heading_bg
          end
          local ok, hl = pcall(vim.api.nvim_get_hl, 0, {
            name = "MarkviewHeading1",
            link = false,
          })
          if ok and hl and hl.bg then
            return hl.bg
          end
          return M.heading_bg_fallback
        end

        local function define_highlights()
          local bg = resolve_heading_bg()
          for _, level in ipairs(M.heading_levels) do
            local opts = { bg = bg, default = true }
            if M.heading_keep_fg then
              local ok, hl = pcall(vim.api.nvim_get_hl, 0, {
                name = "@markup.heading." .. level .. ".markdown",
                link = false,
              })
              if ok and hl and hl.fg then
                opts.fg = hl.fg
                opts.bold = hl.bold
              end
            end
            vim.api.nvim_set_hl(0, "MarkdownH" .. level .. "Line", opts)
          end
          vim.api.nvim_set_hl(0, "MarkdownRule", { fg = M.rule_fg, default = true })
        end

        define_highlights()
        vim.api.nvim_create_autocmd("ColorScheme", {
          desc = "Rebuild markdown decoration highlights",
          callback = define_highlights,
        })

        -- Width available for text, excluding number/sign/fold columns.
        local function text_width(winid)
          local info = vim.fn.getwininfo(winid)[1]
          if not info then
            return vim.api.nvim_win_get_width(winid)
          end
          return math.max(1, info.width - (info.textoff or 0))
        end

        vim.api.nvim_set_decoration_provider(ns, {
          on_win = function(_, _, bufnr, _)
            -- Returning false skips on_line for this window entirely.
            return vim.bo[bufnr].filetype == "markdown"
          end,

          on_line = function(_, winid, bufnr, row)
            local ok, node = pcall(vim.treesitter.get_node, {
              bufnr = bufnr,
              pos = { row, 0 },
            })
            if not ok or not node then
              return
            end

            local ntype = node:type()

            local level = ntype:match("^atx_h(%d)_marker$")
            if level then
              if vim.tbl_contains(M.heading_levels, tonumber(level)) then
                -- `line_hl_group` is ignored on ephemeral extmarks, so paint
                -- the line with hl_group + hl_eol instead.
                vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
                  ephemeral = true,
                  end_row = row + 1,
                  end_col = 0,
                  hl_group = "MarkdownH" .. level .. "Line",
                  hl_eol = true,
                })
              end
              return
            end

            if ntype == "thematic_break" then
              vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
                ephemeral = true,
                virt_text = {
                  { string.rep(M.rule_char, text_width(winid)), "MarkdownRule" },
                },
                virt_text_pos = "overlay",
                hl_mode = "combine",
              })
            end
          end,
        })

        return M
      '';
    };
  };
}
