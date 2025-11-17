{
  config,
  lib,
  helpers,
  ...
}:
{
  # useful code expansions
  # https://github.com/L3MON4D3/LuaSnip
  # https://nix-community.github.io/nixvim/plugins/luasnip
  config = {
    keymaps = helpers.keymaps.mkKeymaps { options.silent = true; } [
      {
        mode = [
          "i"
          "s"
        ];
        key = "<C-f>";
        action.__raw = # lua
          ''
            function()
              local ls = require("luasnip")
              if ls.expand_or_jumpable() then
                ls.expand_or_jump()
              end
            end
          '';
        options.desc = "LuaSnip: Expand or jump forward";
      }
      {
        mode = [
          "i"
          "s"
        ];
        key = "<C-d>";
        action.__raw = # lua
          ''
            function()
              local ls = require("luasnip")
              if ls.jumpable(-1) then
                ls.jump(-1)
              end
            end
          '';
        options.desc = "LuaSnip: Jump backward";
      }
      {
        mode = [
          "i"
          "s"
        ];
        key = "<C-n>";
        action.__raw = # lua
          ''
            function()
              local ls = require("luasnip")
              if ls.choice_active() then
                ls.change_choice(1)
              end
            end
          '';
        options.desc = "LuaSnip: Next choice";
      }
    ];

    plugins.luasnip = {
      enable = true;
      lazyLoad.settings.event = "BufEnter";
      lazyLoad.enable = config.lazyLoad.enable;
      settings = {
        # Press <Tab> to cut visual selection and fill in a snippet
        cut_selection_keys = "<Tab>";
        # TODO: what does this do
        enable_autosnippets = true;
        update_events = [
          "TextChanged"
          "TextChangedI"
        ];

        # annotate nodes with virtual text
        ext_opts =
          let
            types = # lua
              "require('luasnip.util.types')";
          in
          lib.nixvim.toRawKeys {
            "${types}.choiceNode".active.virt_text = [
              [
                "󱥸"
                "TSConditional"
              ]
            ];
            "${types}.insertNode".active.virt_text = [
              [
                "●"
                "TSConstant"
              ]
            ];
            "${types}.functionNode".active.virt_text = [
              [
                "⦿"
                "TSFunction"
              ]
            ];

          };

      };

      # fromVscode = [ { } ];
    };
    # TODO: does this behave the same as `cut_selection_keys`?
    extraConfigLua = # lua
      ''
        local ls = require("luasnip")
        local c = ls.choice_node
        local d = ls.dynamic_node
        local f = ls.function_node
        local i = ls.insert_node
        local r = ls.restore_node
        local s = ls.snippet
        local sn = ls.snippet_node
        local t = ls.text_node
        local extras = require("luasnip.extras")
        local rep = extras.rep
        local fmt = require("luasnip.extras.fmt").fmt
        local fmta = require("luasnip.extras.fmt").fmta
        local postfix = require("luasnip.extras.postfix").postfix

        -- This is the `get_visual` function I've been talking about.
        -- ----------------------------------------------------------------------------
        -- Summary: When `LS_SELECT_RAW` is populated with a visual selection, the function
        -- returns an insert node whose initial text is set to the visual selection.
        -- When `LS_SELECT_RAW` is empty, the function simply returns an empty insert node.
        local get_visual = function(_, parent)
          if (#parent.snippet.env.LS_SELECT_RAW > 0) then
            return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
          else  -- If LS_SELECT_RAW is empty, return a blank insert node
            return sn(nil, i(1))
          end
        end


        -- Example snippet that uses selected text
        ls.add_snippets("all", {
          s({
              trig = "tip",
              dscr = "Optional information to help a user be more successful.",
              name = "[!TIP]",
            },
            fmt([[
                > [!TIP]
                >
                ]],
              {
              }
            )
          ),
          s("link_url", {
            t('<a href="'),
            f(function(_, snip)
              -- TM_SELECTED_TEXT is a table to account for multiline-selections.
              -- In this case only the first line is inserted.
              return snip.env.TM_SELECTED_TEXT[1] or {}
            end, {}),
            t({'">', ""}),
            i(1),
            t({"", "</a>"}),
            i(0),
          }),
          s("link_url2", {
            t('<a href="'),
            f(function(_, snip)
              -- TM_SELECTED_TEXT is a table to account for multiline-selections.
              -- In this case only the first line is inserted.
              return snip.env.TM_SELECTED_TEXT or {}
            end, {}),
            t({'">', ""}),
            i(1),
            t({"", "</a>"}),
            i(0),
          }),
          s("trigger", {
            t({"Wow! Text!", "And another line."})
          }),
          s("ochore", {
            t("chore("),
            i(1),
            t("): "),
            i(2),
            t("(DEL-"),
            i(3),
            t({")", "", "https://console.outsmartly.com/"}),
            rep(1),
            t("/features/"),
            i(0),
          }),
          s("trig", {
            t"text: ", i(1), t{"", "copy: "},
            d(2, function(args)
                -- the returned snippetNode doesn't need a position; it's inserted
                -- "inside" the dynamicNode.
                return sn(nil, {
                  -- jump-indices are local to each snippetNode, so restart at 1.
                  i(1, args[1])
                })
              end,
            {1})
          }),
          s("beg", {
            t"\\begin{", i(1), t"}",
            t{"", "\t"}, i(0),
            t{"", "\\end{"}, rep(1), t"}"
          }),
          s("beg2", fmt(
            [[
            \begin{}
              {}
            \end{}
            ]],
            {
              i(1),
              i(2),
              rep(1)
            }
          )),
          s("example", {
            f(function()
              return "HELLO!"
            end)
          }),
          s("logc", fmt([[Debug.Log($"<color={}>{}</color>");]],
            {
              c(1, {
                t"one",
                t"two",
                t"three",
                t"four"
                -- t"red",
                -- t"orange",
                -- t"yellow",
                -- t"green",
                -- t"blue",
                -- t"indigo",
                -- t"violet",
              }),
              i(2)
            })),
          -- https://github.com/L3MON4D3/LuaSnip/wiki/Cool-Snippets
          s({trig = "table(%d+)x(%d+)", regTrig = true}, {
              d(1, function(_, snip)
                  local nodes = {}
                  local i_counter = 0
                  local hlines = ""
                  for _ = 1, snip.captures[2] do
                      i_counter = i_counter + 1
                      table.insert(nodes, t("| "))
                      table.insert(nodes, i(i_counter, "Column".. i_counter))
                      table.insert(nodes, t(" "))
                      hlines = hlines .. "|---"
                  end
                  table.insert(nodes, t{"|", ""})
                  hlines = hlines .. "|"
                  table.insert(nodes, t{hlines, ""})
                  for _ = 1, snip.captures[1] do
                      for _ = 1, snip.captures[2] do
                          i_counter = i_counter + 1
                          table.insert(nodes, t("| "))
                          table.insert(nodes, i(i_counter))
                          print(i_counter)
                          table.insert(nodes, t(" "))
                      end
                      table.insert(nodes, t{"|", ""})
                  end
                  return sn(nil, nodes)
              end),
            }),
          s({trig = "tii", dscr = "Expands 'tii' into LaTeX's textit{} command."},
              fmta("\\textit{<>}",
                {
                  d(1, get_visual),
                }
              )
            ),
          postfix({ trig = 'kk', dscr = 'Postfix cmd' }, {
                d(1, function(_, parent)
                    print("parent.env", vim.inspect(parent.env))
                    return sn(nil, {
                        t('\\' .. ( parent.env.POSTFIX_MATCH or "")),
                        c(1, {
                            sn(
                                nil,
                                { t('{'), i(1), t('}') }
                            ),
                            t"",
                        }),
                    })
                end),
            }),
          -- postfix(".br", {
          --       f(function(_, parent)
          --           return "[" .. parent.snippet.env.POSTFIX_MATCH .. "]"
          --       end, {}),
          --   })
          -- mainly here to demonstrate how to (properly? see
          -- https://github.com/L3MON4D3/LuaSnip/discussions/1292) use
          -- `LS_SELECT_RAW` and how to combine it with yanked text and
          -- dynamically create node if it matches the pattern
          s("co", {
            d(1, function(_, snip)
              local empty_node = sn(nil, {})
              local ls_select_raw = snip.env.LS_SELECT_RAW or {}
              if type(ls_select_raw) == "string" then
                return empty_node
              end
              local selected_text = table.concat(ls_select_raw, "\n")

              local register_data = vim.fn.getreg() .. ""
              local selected_and_register_data = selected_text .. register_data
              local first_match = string.match(selected_and_register_data, "-?%d+,%s*-?%d+")

              if first_match then
                return sn(nil, {
                  t("position([" .. first_match .. "])")
                })
              else
                vim.notify("Register does not contain the pattern", vim.log.levels.INFO, { title = "LuaSnippet" })
                return empty_node
              end
            end),
          }),
        })
      '';
  };
}
