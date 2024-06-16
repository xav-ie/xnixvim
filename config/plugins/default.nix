{ lib, pkgs, ... }:
{

  plugins = {
    # TODO: consider barbar.enable instead
    # tabs
    bufferline = {
      enable = true;
      separatorStyle = "thin";
      showBufferCloseIcons = false;
      indicator.icon = "▌";
      tabSize = 0;
    };

    # freeeeee auto-complete at least
    # TODO: replace with local version
    codeium-nvim = {
      enable = true;
    };

    # smart comment/uncomment
    comment.enable = true;

    # auto-formatting
    conform-nvim = {
      enable = true;
      # Map of filetype to formatters
      formattersByFt =
        let
          prettierFormat = [
            [
              # prefer the node_module prettier
              "prettier"
              # fallback to global prettier
              "${pkgs.nodePackages.prettier}/bin/prettier"
            ]
          ];
        in
        {
          lua = [ "stylua" ];
          html = prettierFormat;
          markdown = prettierFormat;
          javascript = prettierFormat;
          javascriptreact = prettierFormat;
          json = prettierFormat;
          jsonc = prettierFormat;
          typescript = prettierFormat;
          typescriptreact = prettierFormat;
          nix = [ "nixfmt" ];
          # Use the "*" filetype to run formatters on all filetypes.
          #"*" = [ "codespell" ];
          # Use the "_" filetype to run formatters on filetypes that don't
          # have other formatters configured.
          "_" = [ "trim_whitespace" ];
        };
      formatOnSave = {
        timeoutMs = 500;
        lspFallback = true;
      };
    };

    flash = {
      enable = true;
      # autojump when there is only one match
      jump.autojump = true;
    };

    # the best git plugin
    fugitive.enable = true;

    # amazing snippets for every language
    friendly-snippets.enable = true;

    # git indicators in the left gutter
    gitsigns = {
      enable = true;
      settings = {
        current_line_blame = true;
        current_line_blame_opts = {
          virt_text = true;
          virt_text_pos = "right_align";
          delay = 0;
          ignore_whitespace = false;
          virt_text_priority = 100;
        };
        # TODO: comb through and make better
        # https://github.com/fpletz/flake/blob/f97512e2f7cfb555bcebefd96f8cf61155b8dc42/home/nixvim/gitsigns.nix#L21
        on_attach = # lua
          ''
            function(bufnr)
              local gs = package.loaded.gitsigns

              local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
              end

              -- Register key mappings and descriptions using which-key
              local wk = require("which-key")
              wk.register({
                  ["]c"] = { function()
                      if vim.wo.diff then return "]c" end
                      vim.schedule(function() gs.next_hunk() end)
                      return '<Ignore>'
                  end, "Next Hunk" },
                  ["[c"] = { function()
                      if vim.wo.diff then return "[c" end
                      vim.schedule(function() gs.prev_hunk() end)
                      return '<Ignore>'
                  end, "Previous Hunk" },
                  ["<leader>"] = {
                      h = {
                          name = "Gitsigns",
                          s = { ":Gitsigns stage_hunk<CR>", "Stage Hunk" },
                          r = { ":Gitsigns reset_hunk<CR>", "Reset Hunk" },
                          S = { gs.stage_buffer, "Stage Buffer" },
                          u = { gs.undo_stage_hunk, "Undo Stage Hunk" },
                          R = { gs.reset_buffer, "Reset Buffer" },
                          p = { gs.preview_hunk, "Preview Hunk" },
                          b = { function() gs.blame_line{full=true} end, "Blame Full Line" },
                          d = { gs.diffthis, "Diff This" },
                          D = { function() gs.diffthis('~') end, "Diff This ~" },
                      },
                      t = {
                          name = "Toggle",
                          b = { gs.toggle_current_line_blame, "Toggle Line Blame" },
                          d = { gs.toggle_deleted, "Toggle Deleted" },
                      }
                  }
              }, { mode = "n", buffer = bufnr, silent = true, noremap = true, nowait = true })

              -- Text object
              map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
            end
          '';
      };
    };

    lsp = {
      enable = true;
      keymaps = {
        silent = true;
        diagnostic = {
          # Navigate in diagnostics
          "[d" = "goto_prev";
          "]d" = "goto_next";
          "<leader>d" = "open_float";
        };

        lspBuf = {
          gd = "definition";
          gD = "references";
          gt = "type_definition";
          gi = "implementation";
          K = "hover";
          "<leader>r" = "rename";
        };
      };
      #onAttach = ''
      #  vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
      #'';
      servers = {
        eslint.enable = true;
        gopls.enable = true;
        graphql.enable = true;
        jsonls = {
          enable = true;
          extraOptions.settings.json = {
            schemas.__raw = # lua
              ''
                require('schemastore').json.schemas {
                  replace = {
                    -- Micro editor config is currently too greedy
                    ['A micro editor config'] = {
                      description = "A micro editor config",
                      fileMatch = { "settings.json" },
                      name = "A micro editor config",
                      url = "https://json.schemastore.org/micro.json"
                    },
                  },
                }
              '';
            validate.enable = true;
          };
        };
        lua-ls.enable = true;
        nil_ls = {
          enable = true;
          settings.formatting.command = [ "nixfmt-rfc-style" ];
        };
        rust-analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
        };
        denols = {
          enable = true;
          rootDir = # lua
            ''
              require('lspconfig').util.root_pattern("deno.json", "deno.jsonc")
            '';
          extraOptions.init_options = {
            lint = true;
            unstable = true;
          };
        };
        tsserver = {
          enable = true;
          onAttach.function = # lua
            ''
              if client.server_capabilities.inlayHintProvider then
                vim.lsp.inlay_hint.enable(true)
              end
            '';
          extraOptions = {
            single_file_support = false;
            settings =
              let
                inlayHints = {
                  includeInlayEnumMemberValueHints = true;
                  includeInlayFunctionLikeReturnTypeHints = true;
                  includeInlayFunctionParameterTypeHints = true;
                  includeInlayParameterNameHints = "all";
                  includeInlayParameterNameHintsWhenArgumentMatchesName = true;
                  includeInlayPropertyDeclarationTypeHints = true;
                  includeInlayVariableTypeHints = true;
                };
              in
              {
                javascript = {
                  inherit inlayHints;
                };
                typescript = {
                  inherit inlayHints;
                };
              };
            commands = {
              OrganizeImports.__raw = # lua
                ''
                  {
                    function()
                      vim.lsp.buf.execute_command {
                        title = "",
                        command = "_typescript.organizeImports",
                        arguments = { vim.api.nvim_buf_get_name(0) },
                      }
                    end,
                    description = "Organize Imports",
                  }
                '';
            };
            rootDir = # lua
              ''
                require('lspconfig').util.root_pattern("package.json")
              '';
          };
        };
      };
    };

    # completion icons
    lspkind = {
      enable = true;
      cmp = {
        enable = true;
      };
    };

    # better diagnostics ui
    lsp-lines = {
      enable = true;
      # currentLine = true;
    };

    # statusline
    lualine = {
      enable = true;
      theme = lib.mkForce "powerline_dark";
      globalstatus = true;
      # idk if this does anything
      componentSeparators = {
        left = ""; # "";
        right = ""; # "";
      };
      sectionSeparators = {
        left = ""; # "";
        right = ""; # "";
      };

      # Available Sections:
      # A lot of these include reasonable extra logos/logic for display:
      # branch, buffers, diagnostics, diff, encoding, fileformat, 
      # filename, filesize, filetype, hostname, location, mode, 
      # progress, searchcount, selectioncount, tabs, windows
      # Raw things:
      # %t (filename), %c (column), %l (line), %p (percentage), %{any expression}
      sections = {
        lualine_a = [
          {
            name = "mode";
            fmt = "function(str) return str:sub(1,1) end";
          }
        ];
        lualine_b = [
          {
            name = "branch";
            icons_enabled = false;
          }
        ];
        lualine_c = [
          {
            name = "%{&readonly?&buftype=='help'?'📚 ':'🔒 ':''}%t"; # %{&modified?'*':''}
            color.__raw = "function() return vim.bo.modified and { fg = '#FFAA00' } or {} end";
            extraConfig.cond.__raw = "function() return vim.bo.filetype ~= 'oil' end";
          }
          # IDK why, but the extension does not seem to work properly
          {
            name = "";
            color.__raw = "function() return vim.bo.modified and { fg = '#FFAA00' } or {} end";
            fmt = # lua
              ''
                function()
                  local ok, oil = pcall(require, 'oil')
                  if ok then
                    return vim.fn.fnamemodify(oil.get_current_dir(), ':~')
                  else
                    return ""
                  end
                end
              '';
            extraConfig.cond.__raw = "function() return vim.bo.filetype == 'oil' end";
          }
        ];
        lualine_x = [
          "searchcount"
          "selectioncount"
          {
            name = "diff";
            # use gitsigns diff instead of manually recalculating it
            # https://github.com/nvim-lualine/lualine.nvim/wiki/Component-snippets
            extraConfig.source.__raw = # lua
              ''
                function() 
                  local gitsigns = vim.b.gitsigns_status_dict
                    if gitsigns then
                      return {
                        added = gitsigns.added,
                        modified = gitsigns.changed,
                        removed = gitsigns.removed
                      }
                    end
                end
              '';
          }
          "diagnostics"
        ];
        lualine_y = [
          {
            name = "filetype";
            color = {
              bg = "Black"; # some icons are hard to see
            };
          }
        ];
        lualine_z = [
          {
            name = "";
            fmt = # lua
              ''
                function(str)
                  local function progress()
                    local cur = vim.fn.line('.')
                    local total = vim.fn.line('$')
                    if cur == 1 then
                      return ' 0'
                    elseif cur == total then
                      return '00'
                    else
                      return string.format('%2d', math.floor(cur / total * 100))
                    end
                  end
                  return ('%2c:' .. progress())
                end
              '';
          }
        ];
      };

      # what sections to show in inactive windows
      # N/A bc I disabled it on other subwindows
      # inactiveSections = { };
    };

    # useful code expansions
    luasnip = {
      enable = true;
      extraConfig = {
        #   enable_autosnippets = true;
        #   store_selection_keys = “<Tab>”;
      };
      fromVscode = [ { } ];
    };
    # luasnip expansions in cmp
    cmp_luasnip.enable = true;

    # TODO: figure out if this is possible with just treesitter?
    # nix.enable = true;

    ollama = {
      enable = true;
      model = "codellama";
    };

    noice = {
      enable = true;
      messages = {
        view = "mini";
        viewError = "mini";
        viewWarn = "mini";
      };

      lsp.override = {
        "vim.lsp.util.convert_input_to_markdown_lines" = true;
        "vim.lsp.util.stylize_markdown" = true;
        "cmp.entry.get_documentation" = true;
      };

      presets = {
        bottom_search = true;
        command_palette = true;
        long_message_to_split = true;
        inc_rename = true;
        lsp_doc_border = true;
      };
    };

    # ()[]{}...
    nvim-autopairs.enable = true;

    # completions
    cmp = {
      enable = true;
      # only works when sources is not set with __raw
      autoEnableSources = true;
      settings = {
        sources = [
          { name = "nvim_lsp"; }
          { name = "codeium"; }
          { name = "luasnip"; }
          { name = "path"; }
          {
            name = "buffer";
            # Words from other open buffers can also be suggested.
            option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
          }
          # idk what this one is
          # { name = "calc"; }
          # TODO: {name = "neorg";}
        ];
        mapping = {
          "<C-u>" = "cmp.mapping.scroll_docs(-3)";
          "<C-d>" = "cmp.mapping.scroll_docs(3)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<tab>" = "cmp.mapping.close()";
          "<c-n>" = "cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert })";
          "<c-p>" = "cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert })";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
        };
        snippet.expand = # lua
          ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';
      };
      # extraOptions.experimental = {
      #   ghost_text = true;
      # };
    };

    # colors in neovim
    nvim-colorizer.enable = true;

    # TODO: figure out if this is good or not
    # vscode lightbulbs
    # nvim-lightbulb = {
    #   enable = true;
    #   autocmd.enabled = true;
    # };

    # better folding ui
    #nvim-ufo.enable = true;

    # easily browse directories
    oil = {
      enable = true;
      settings = {
        view_options = {
          show_hidden = true;
        };
        win_options = {
          signcolumn = "yes:2";
        };
      };
    };

    # tpope === goat
    surround.enable = true;

    # fzf client
    # https://github.com/BenjaminTalbi/nixos-configurations/blob/0f160eaa0eae5a0417bc3eafae5e5e389614bda2/home/nixvim/telescope.nix
    telescope = {
      enable = true;
      settings = {
        defaults = {
          file_ignore_patterns = [
            "^.git/"
            "^.mypy_cache/"
            "^__pycache__/"
            "%.ipynb"
            "^node_modules/"
            "^dist/"
            "%.generated.%"
          ];
          set_env.COLORTERM = "truecolor";
          mappings =
            let
              flash = # lua
                ''
                  function(prompt_bufnr)
                      require("flash").jump({
                          pattern = "^",
                          label = { after = { 0, 0 } },
                          search = {
                              mode = "search",
                              exclude = {
                                  function(win)
                                      return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
                                  end,
                              },
                          },
                          action = function(match)
                              local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
                              picker:set_selection(match.pos[1] - 1)
                          end,
                      })
                  end
                '';
            in
            {
              i =
                let
                  actions = "require('telescope.actions')";
                in
                {
                  "<C-j>".__raw = "${actions}.move_selection_next";
                  "<C-k>".__raw = "${actions}.move_selection_previous";
                  "<C-q>".__raw = "${actions}.smart_send_to_qflist + ${actions}.open_qflist";
                  "<A-q>".__raw = "${actions}.smart_add_to_qflist + ${actions}.open_qflist";
                  "<C-s>".__raw = "${flash}";
                  # TODO: add file filtering command
                };
              n = {
                "s".__raw = "${flash}";
              };
            };
        };
      };

      keymaps = {
        "<leader>ff" = {
          action = "find_files";
          options.desc = "find_[f]iles";
        };
        "<leader>fg" = {
          action = "git_files";
          options.desc = "[g]it_files";
        };
        "<leader>fl" = {
          action = "live_grep";
          options.desc = "[l]ive_grep";
        };
        "<leader>fo" = {
          action = "oldfiles";
          options.desc = "[o]ldfiles";
        };
        "<leader>fr" = {
          action = "resume";
          options.desc = "[R]esume Previous Seasch";
        };
        "<leader>fs" = {
          action = "lsp_document_symbols";
          options.desc = "lsp_document_[s]ymbols";
        };
        # "<leader>fu" = { action = "undo"; desc = "undo"; };
        "<leader>fw" = {
          action = "grep_string";
          options.desc = "grep_string";
        };
      };
      extensions = {
        fzf-native = {
          enable = true;
          settings = {
            fuzzy = true;
            override_files_sorter = true;
          };
        };
        undo = {
          enable = true;
        };
      };
    };

    todo-comments.enable = true;

    # ast syntax highlighting
    treesitter = {
      enable = true;
      # TODO: figure out how to make this not open files pre-folded
      # fold based on ast
      # folding = true;

      # this is handled by orgmode plugin
      ignoreInstall = [ "org" ];
      # indent based on ast
      indent = true;
      # lua highlighting for nixvim lua sections
      nixvimInjections = true;
      # this is SO useful
      incrementalSelection = {
        enable = true;
        keymaps = {
          initSelection = "<C-space>";
          nodeDecremental = "<bs>";
          nodeIncremental = "<C-space>";
          # idk what this does
          scopeIncremental = "grc";
        };
      };
    };

    # diagnostics buffer
    trouble.enable = true;

    # even better %
    vim-matchup = {
      treesitterIntegration = {
        enable = true;
        includeMatchWords = true;
      };
      enable = true;
    };

    # TODO: see https://github.com/Alexnortung/nollevim/blob/fcc35456c567c6108774e839d617c97832217e67/config/which-key.nix#L4
    which-key.enable = true;

    # zellij = {
    #   enable = true;
    #
    #   settings = {
    #     debug = true;
    #     vimTmuxNavigatorKeybinds = true;
    #     whichKeyEnabled = true;
    #     replaceVimWindowNavigationKeybinds = true;
    #   };
    # };
  };
}
