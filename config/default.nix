{
  lib,
  helpers,
  pkgs,
  neovim-nightly-overlay,
  system,
  ...
}:
let
  octo-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "octo.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "pwntester";
      repo = "octo.nvim";
      rev = "5646539320cd62af6ff28f48ec92aeb724c68e18";
      hash = "sha256-EK05b72/ekNcA7RBauiKZ27/rF4YX6IXnzRpODzXduI=";
    };
  };
  oatmeal-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "oatmeal.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "dustinblackman";
      repo = "oatmeal.nvim";
      rev = "c8cdd0a182cf77f88ea5fa4703229ddb3f47c1f7";
      hash = "sha256-YqGOAZ8+KRYJbOIVHD9yreL7ZvBwbWeKwsM/oV6r3Ic=";
    };
  };
  # idk what the difference is in package builders 
  oil-git-status = pkgs.vimUtils.buildVimPlugin {
    name = "oil-git-status.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "refractalize";
      repo = "oil-git-status.nvim";
      rev = "839a1a287f5eb3ce1b07b50323032398e63f7ffa";
      hash = "sha256-pTAvkJPmT3eD3XWrYl6nyKSzeRFEHOi8iDCamF1D1Cg=";
    };
  };
  SchemaStore-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "SchemaStore.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "b0o";
      repo = "SchemaStore.nvim";
      rev = "cf82be744f4dba56d5d0c13d7fe429dd1d4c02e7";
      hash = "sha256-bAsSHBdxdwfHZ3HiU/wyeoS/FiQNb3a/TB2lQOz/glA=";
    };
  };
  markdown-table-sorter = pkgs.vimUtils.buildVimPlugin {
    name = "markdown-table-sorter";
    src = ./custom-plugins/markdown-table-sorter;
  };
in
{
  # TODO:
  # [ ] checkout ts-auto-tag:
  #     https://github.com/pta2002/nixos-config/blob/main/modules/nvim.nix
  # [ ] checkout these other plugins:
  #  https://github.com/Alexnortung/nollevim/blob/fcc35456c567c6108774e839d617c97832217e67/config/appearance/treesitter.nix#L2
  # [ ] lsp code actions with telescope?
  # https://github.com/nvim-telescope/telescope-ui-select.nvim
  #  https://github.com/traxys/nvim-flake/blob/c753bb1e624406ef454df9e8cb59d0996000dc93/config.nix#L306
  # [ ] read through these config(s) fully:
  #  https://github.com/Builditluc/dotfiles/blob/0989f7bf0d147232b4133d9fe4fb166465e93b94/dotnix/hm/nvim.nix#L95
  #  https://github.com/pta2002/nixos-config/blob/main/modules/nvim.nix
  # https://github.com/evccyr/dotfiles/blob/main/nix/neovim/default.nix
  # [ ] would git blame floating messages be helpful? https://github.com/rhysd/git-messenger.vim
  # [ ] is lspsaga any good? looks kind of bloated and feature creeped.
  # [ ] write my own or find someone else's snippets for ts. specifically all the map, reduce, forEach should have snippets
  #  https://www.youtube.com/watch?v=Dn800rlPIho
  #  https://github.com/L3MON4D3/LuaSnip#resources-for-new-users
  #  https://www.youtube.com/watch?v=FmHhonPjvvA
  # [ ] harpoon?
  # [ ] flash nvim for faster jumping
  # [ ] eslint with conform? or none-ls? idk the real differences yet

  # Import all your configuration modules here
  imports = [ ./bufferline.nix ];
  config = {
    colorschemes = {
      base16 = {
        enable = true;
        #colorscheme = "pinky";
        #colorscheme = "colors";
        #colorscheme = "purpledream";
        # somehow, gatekeeper theme from nvchad is based on pico
        # but this looks bad, but I love gatekeeper
        #colorscheme = "pico";
        colorscheme = {
          # background
          base00 = "NONE";
          # active tab, ui tab foreground
          base01 = "#603090";
          # highlight text color
          base02 = "#1060ee";
          # comments
          base03 = "#a090a0";
          # line number color
          base04 = "#a0a0ff";
          # special characters ()=>{}
          base05 = "#e0e0e0";
          # ???
          base06 = "#00ff00";
          # ???
          base07 = "#a0a000";
          # html tags, variables, attributes, ui tab background
          base08 = "#FFB20F";
          # values
          base09 = "#00a0f0";
          # types, html attributes
          base0A = "#BE620A";
          # strings, unsaved tab, ui tab background
          base0B = "#00E756";
          # ???
          base0C = "#FFD242";
          # values
          base0D = "#9A5FEB";
          # keywords, function calls
          base0E = "#ff3a8e";
          # special characters, semi-colons, commas
          base0F = "#f06949";
        };
      };
    };

    package = neovim-nightly-overlay.packages."${system}".default;
    extraConfigLua = # lua
      ''
        vim.opt.cmdheight = 0;

        -- add border to diagnostic windows
        local _border = "single"
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
          border = _border,
        })
        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
          border = _border,
        })
        vim.diagnostic.config {
          float = { border = _border },
        }

        local function paste()
         -- this is inaccurate and not correct, but it is okay enough
         return {vim.fn.split(vim.fn.getreg(""), '\n'), vim.fn.getregtype("")}
        end

        vim.g.clipboard = {
          name = 'OSC 52',
          copy = {
            ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
            ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
          },
          paste = {
            ['+'] = paste,
            ['*'] = paste,
            -- TODO: get osc paste working for zellij first
            -- ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
            -- ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
          },
        }

        -- I always want yanks syncronized with system and "selection" (idk what that is) clipboard
        -- https://github.com/ch3n9w/dev/blob/319deb662ff50b58f5b643fbd9327ecb00919886/nvim/lua/autocmd.lua#L26-L34
        vim.api.nvim_create_autocmd('TextYankPost', {
            callback = function()
                vim.highlight.on_yank()
                local copy_to_unnamedplus = require('vim.ui.clipboard.osc52').copy('+')
                copy_to_unnamedplus(vim.v.event.regcontents)
                local copy_to_unnamed = require('vim.ui.clipboard.osc52').copy('*')
                copy_to_unnamed(vim.v.event.regcontents)
            end
        })
        -- I also want paste syncronized, too, but zellij is preventing this >:(

        -- TODO: how to use colorscheme
        vim.cmd('highlight TSProperty guifg=#FFD242')
        vim.cmd('highlight TSType guifg=#00a0f0')
        vim.cmd('highlight TSNumber guifg=#be620a')

        -- TODO: improve docs and package
        require('markdown-table-sorter')
        require('oil-git-status').setup()
        require('oatmeal').setup({backend='ollama', model='codellama:latest'})
        require('octo').setup({
          suppress_missing_scope = {
            projects_v2 = true,
          },
        })
      '';

    extraPlugins = [
      markdown-table-sorter
      octo-nvim
      oatmeal-nvim
      oil-git-status
      SchemaStore-nvim
    ];

    extraPackages = with pkgs; [
      git
      ripgrep
      prettierd
      nixfmt-rfc-style
      stylua
    ];
    # with pkgs.vimPlugins; [
    # friendly-snippets
    # ];

    globals = {
      # merge statusbar into command bar
      # ...except, this does not work :/
      # cmdheight = 0;
      mapleader = " ";
      # 24-bit colors
      termguicolors = true;
      # don't care about case when search
      ignorecase = true;
      # ...unless you used uppercase
      smartcase = true;
    };

    # TODO: clean this up
    highlight = {
      ColorColumn = {
        underline = true;
      };

      PmenuSel = {
        bg = "#504945";
        fg = "NONE";
      };
      Pmenu = {
        fg = "#ebdbb2";
        bg = "#282828";
      };

      CmpItemAbbrDeprecated = {
        fg = "#d79921";
        bg = "NONE";
        strikethrough = true;
      };
      CmpItemAbbrMatch = {
        fg = "#83a598";
        bg = "NONE";
        bold = true;
      };
      CmpItemAbbrMatchFuzzy = {
        fg = "#83a598";
        bg = "NONE";
        bold = true;
      };
      CmpItemMenu = {
        fg = "#b16286";
        bg = "NONE";
        italic = true;
      };

      CmpItemKindField = {
        fg = "#fbf1c7";
        bg = "#fb4934";
      };
      CmpItemKindProperty = {
        fg = "#fbf1c7";
        bg = "#fb4934";
      };
      CmpItemKindEvent = {
        fg = "#fbf1c7";
        bg = "#fb4934";
      };

      CmpItemKindText = {
        fg = "#fbf1c7";
        bg = "#b8bb26";
      };
      CmpItemKindEnum = {
        fg = "#fbf1c7";
        bg = "#b8bb26";
      };
      CmpItemKindKeyword = {
        fg = "#fbf1c7";
        bg = "#b8bb26";
      };

      CmpItemKindConstant = {
        fg = "#fbf1c7";
        bg = "#fe8019";
      };
      CmpItemKindConstructor = {
        fg = "#fbf1c7";
        bg = "#fe8019";
      };
      CmpItemKindReference = {
        fg = "#fbf1c7";
        bg = "#fe8019";
      };

      CmpItemKindFunction = {
        fg = "#fbf1c7";
        bg = "#b16286";
      };
      CmpItemKindStruct = {
        fg = "#fbf1c7";
        bg = "#b16286";
      };
      CmpItemKindClass = {
        fg = "#fbf1c7";
        bg = "#b16286";
      };
      CmpItemKindModule = {
        fg = "#fbf1c7";
        bg = "#b16286";
      };
      CmpItemKindOperator = {
        fg = "#fbf1c7";
        bg = "#b16286";
      };

      CmpItemKindVariable = {
        fg = "#fbf1c7";
        bg = "#458588";
      };
      CmpItemKindFile = {
        fg = "#fbf1c7";
        bg = "#458588";
      };

      CmpItemKindUnit = {
        fg = "#fbf1c7";
        bg = "#d79921";
      };
      CmpItemKindSnippet = {
        fg = "#fbf1c7";
        bg = "#d79921";
      };
      CmpItemKindFolder = {
        fg = "#fbf1c7";
        bg = "#d79921";
      };

      CmpItemKindMethod = {
        fg = "#fbf1c7";
        bg = "#8ec07c";
      };
      CmpItemKindValue = {
        fg = "#fbf1c7";
        bg = "#8ec07c";
      };
      CmpItemKindEnumMember = {
        fg = "#fbf1c7";
        bg = "#8ec07c";
      };

      CmpItemKindInterface = {
        fg = "#fbf1c7";
        bg = "#83a598";
      };
      CmpItemKindColor = {
        fg = "#fbf1c7";
        bg = "#83a598";
      };
      CmpItemKindTypeParameter = {
        fg = "#fbf1c7";
        bg = "#83a598";
      };

      FloatBorder = {
        fg = "#a89984";
      };
    };

    keymaps =
      # taken from https://github.com/traxys/nvim-flake/blob/c753bb1e624406ef454df9e8cb59d0996000dc93/config.nix#L94-L107
      let
        modeKeys =
          mode:
          lib.attrsets.mapAttrsToList (
            key: action:
            { inherit key mode; } // (if builtins.isString action then { inherit action; } else action)
          );
        nm = modeKeys [ "n" ];
        vs = modeKeys [ "v" ];
        im = modeKeys [ "i" ];
      in
      helpers.keymaps.mkKeymaps { options.silent = true; } (nm {
        "-" = "<cmd>Oil<CR>";
        "bp" = "<cmd>Telescope buffers<CR>";
        "<C-s>" = "<cmd>Telescope spell_suggest<CR>";
        "mk" = "<cmd>Telescope keymaps<CR>";
        "<leader>fu" = "<cmd>Telescope undo<CR>";
        # lsp navigation
        "gr" = "<cmd>Telescope lsp_references<CR>";
        "gI" = "<cmd>Telescope lsp_implementations<CR>";
        "gW" = "<cmd>Telescope lsp_workspace_symbols<CR>";
        "gF" = "<cmd>Telescope lsp_document_symbols<CR>";
        "ge" = "<cmd>Telescope diagnostics bufnr=0<CR>";
        "gE" = "<cmd>Telescope diagnostics<CR>";
        # remove highlights
        "<Esc>" = ":noh <CR>";
        # window navigation
        "<C-h>" = "<C-w>h";
        "<C-l>" = "<C-w>l";
        "<C-j>" = "<C-w>j";
        "<C-k>" = "<C-w>k";
        # buffer navigation
        "<tab>" = ":bnext <CR>";
        "<S-tab>" = ":bprevious <CR>";
        "<leader>x" = ":bdelete <CR>";
      })
      ++ (vs {
        "<leader>/" = "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>";
        "<leader>?" = "<ESC><cmd>lua require('Comment.api').toggle.blockwise(vim.fn.visualmode())<CR>";
      })
      ++ (im {
        "<C-e>" = "<End>";
        "<C-b>" = "<ESC>^i";
        "<C-h>" = "<Left>";
        "<C-j>" = "<Down>";
        "<C-k>" = "<Up>";
        "<C-l>" = "<Right>";
      })
      ++ [
        {
          key = "<leader>/";
          mode = [ "n" ];
          action = ''
            function() 
             require("Comment.api").toggle.linewise.current()
            end
          '';
          lua = true;
          options.expr = true;
        }
        {
          key = "<leader>?";
          mode = [ "n" ];
          action = ''
            function() 
             require("Comment.api").toggle.blockwise.current()
            end
          '';
          lua = true;
          options.expr = true;
        }
        {
          key = "<leader>rn";
          mode = [ "n" ];
          action = ''
            function()
             return ":IncRename " .. vim.fn.expand("<cword>")
            end
          '';
          lua = true;
          options.expr = true;
        }
        {
          key = "<leader>fm";
          mode = [ "n" ];
          action = ''
            function()
              vim.lsp.buf.format { async = true }
            end
          '';
          lua = true;
          options = {
            desc = "LSP formatting";
            expr = true;
          };
        }
      ];

    match = {
      ColorColumn = "\\%101v";
    };

    opts = {
      number = true; # Show line numbers
      relativenumber = false;
      shiftwidth = 2; # Tab width should be 2
      tabstop = 2;
      softtabstop = 2;
      smartindent = true;
      expandtab = true;
    };

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
                "prettierd"
                "prettier"
              ]
            ];
          in
          {
            lua = [ "stylua" ];
            # It is kind of weird that you can't reference the actual bin formatter... or can you?
            # I think you can do it this way, but the current way seems to work okay.
            # "${pkgs.prettierd}/bin/prettierd"
            html = prettierFormat;
            markdown = prettierFormat;
            javascript = prettierFormat;
            javascriptreact = prettierFormat;
            # Should I be using jsonc?
            json = prettierFormat;
            # idek
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

      # indentation lines ui guides
      # indent-blankline.enable = true;

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
            settings.formatting.command = [ "nixpkgs-fmt" ];
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
                # TODO: figure out how to use this
                # https://github.com/jakehamilton/neovim/blob/9375031a8da6a654bf0f971d23c302f2fb555b35/modules/nixvim/lsp/default.nix#L95
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
            ];
            set_env.COLORTERM = "truecolor";
            mappings = {
              i =
                let
                  actions = "require('telescope.actions')";
                in
                {
                  "<C-j>".__raw = "${actions}.move_selection_next";
                  "<C-k>".__raw = "${actions}.move_selection_previous";
                  "<C-q>".__raw = "${actions}.smart_send_to_qflist + ${actions}.open_qflist";
                  "<A-q>".__raw = "${actions}.smart_add_to_qflist + ${actions}.open_qflist";
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
  };
}
