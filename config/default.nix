{
  lib,
  helpers,
  pkgs,
  neovim-nightly-overlay,
  system,
  ...
}:
let
  # octo-nvim = pkgs.vimUtils.buildVimPlugin {
  #   name = "octo.nvim";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "pwntester";
  #     repo = "octo.nvim";
  #     rev = "5646539320cd62af6ff28f48ec92aeb724c68e18";
  #     hash = "sha256-EK05b72/ekNcA7RBauiKZ27/rF4YX6IXnzRpODzXduI=";
  #   };
  # };
  orgmode = pkgs.vimUtils.buildVimPlugin {
    name = "orgmode";
    src = pkgs.fetchFromGitHub {
      owner = "nvim-orgmode";
      repo = "orgmode";
      rev = "0.3.4";
      hash = "sha256-SmofuYt4fLhtl5qedYlmCRgOmZaw3nmlnMg0OMzyKnM=";
    };
  };
  org-roam-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "org-roam.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "chipsenkbeil";
      repo = "org-roam.nvim";
      rev = "0.1.0";
      hash = "sha256-n7GrZrM5W7QvM7805Li0VEBKc23KKbrxG3voL3otpLw=";
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
  # IDK what the difference is in package builders 
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
  # [ ] LSP code actions with telescope?
  # https://github.com/nvim-telescope/telescope-ui-select.nvim
  #  https://github.com/traxys/nvim-flake/blob/c753bb1e624406ef454df9e8cb59d0996000dc93/config.nix#L306
  # [ ] read through these config(s) fully:
  #  https://github.com/Builditluc/dotfiles/blob/0989f7bf0d147232b4133d9fe4fb166465e93b94/dotnix/hm/nvim.nix#L95
  #  https://github.com/pta2002/nixos-config/blob/main/modules/nvim.nix
  #  https://github.com/evccyr/dotfiles/blob/main/nix/neovim/default.nix
  #  https://github.com/prescientmoon/everything-nix/blob/82fca70a6e882365a76e947cc0e01db07d6cc13c/home/features/neovim/default.nix
  #  https://github.com/NickHu/nixvim-flake/blob/1f47b9cfb5d8e86a48cf8d64bfb3fd0389d14f75/config/default.nix
  #  https://github.com/SchnozzleCat/Nix/blob/160e617a28ef25be2311445fc407ca54e53437a7/home/neovim.nix
  # [ ] write my own or find someone else's snippets for ts. specifically all the map, reduce, forEach should have snippets
  #  https://www.youtube.com/watch?v=Dn800rlPIho
  #  https://github.com/L3MON4D3/LuaSnip#resources-for-new-users
  #  https://www.youtube.com/watch?v=FmHhonPjvvA
  # [ ] harpoon?

  # Import all your configuration modules here
  imports = [ ./plugins ];
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
        -- corrects command auto-complete to take fullest match but not overfill
        -- full allows the list itself to also show still
        vim.opt.wildmode = "longest:full";
        vim.opt.spelllang = "en_us";
        vim.opt.spell = true;
        -- Not currently working. See other configurations on GitHub.
        vim.opt.spellfile = "~/.config/nvim/spell/en_us.utf-8.add";

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
            -- TODO: get OSC paste working for Zellij first
            -- ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
            -- ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
          },
        }

        -- I always want yanks synchronized with system and "selection" (IDK what that is) clipboard
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
        -- I also want paste synchronized, too, but Zellij is preventing this >:(

        -- TODO: how to use color scheme
        vim.cmd('highlight TSProperty guifg=#FFD242')
        vim.cmd('highlight TSType guifg=#00a0f0')
        vim.cmd('highlight TSNumber guifg=#be620a')

        -- TODO: improve docs and package
        require('markdown-table-sorter')
        require('oil-git-status').setup()
        require('oatmeal').setup({backend='ollama', model='codellama:latest'})
        require("orgmode").setup({})
        require("org-roam").setup({
          directory = "~/Notes",
        })
        -- require('octo').setup({
        --   suppress_missing_scope = {
        --     projects_v2 = true,
        --   },
        -- })

        -- Pascal Case, also highlights the cased words for easy lower-casing! :)
        vim.api.nvim_set_keymap('v', 'gp', [[:<C-u>'<,'>s/\%V\v\w+/\u\L&/g<CR>]], { noremap = true, silent = true })
        -- Title Case
        vim.api.nvim_set_keymap('v', 'gt', [[:<C-u>'<,'>s/\%V\v\w+/\u\L&/g<CR>:<C-u>silent! '<,'>s/\%V\<\(A\|An\|The\|And\|But\|Or\|Nor\|So\|Yet\|At\|By\|In\|Of\|On\|To\|Up\|For\|About\|Above\|Across\|After\|Against\|Along\|Among\|Around\|Before\|Behind\|Below\|Beneath\|Beside\|Between\|Beyond\|Down\|During\|Except\|From\|Inside\|Into\|Like\|Near\|Off\|Onto\|Out\|Outside\|Over\|Past\|Since\|Through\|Throughout\|Under\|Underneath\|Until\|With\|Within\|Without\|Is\|Be\|Am\|Are\|Was\|Were\|Has\|Have\|Had\)\>/\L&/g<CR>]], { noremap = true, silent = true })
        -- Sentence case
        vim.api.nvim_set_keymap('v', 'gs', [[:<C-u>try | '<,'>s/\%V\(\(^\|[.!?]\s*\)\)\zs\w/\u&/g | catch | endtry<CR>:<C-u>'<,'>normal! _vgU<CR>]], { noremap = true, silent = true })
        -- Stolen from nekowinston
        vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
          callback = function(data)
            local msg = data.event == "RecordingEnter" and "Recording macro..." or "Macro recorded"
            vim.notify(msg, vim.log.levels.INFO, { title = "Macro" })
          end,
          desc = "Notify when recording macro",
        })
      '';

    extraPlugins = [
      markdown-table-sorter
      oatmeal-nvim
      # octo-nvim
      oil-git-status
      orgmode
      org-roam-nvim
      SchemaStore-nvim
    ];

    extraPackages = with pkgs; [
      git
      ripgrep
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
          action = # lua
            ''function() require("Comment.api").toggle.linewise.current() end'';
          lua = true;
          options.expr = true;
        }
        {
          key = "<leader>?";
          mode = [ "n" ];
          action = # lua
            ''function() require("Comment.api").toggle.blockwise.current() end'';
          lua = true;
          options.expr = true;
        }
        {
          key = "<leader>rn";
          mode = [ "n" ];
          action = # lua
            ''function() return ":IncRename " .. vim.fn.expand("<cword>") end'';
          lua = true;
          options.expr = true;
        }
        {
          key = "<leader>fm";
          mode = [ "n" ];
          action = # lua
            ''function() vim.lsp.buf.format { async = true } end'';
          lua = true;
          options = {
            desc = "LSP formatting";
            expr = true;
          };
        }
        {
          mode = [ "c" ];
          key = "<C-s>";
          options = {
            silent = true;
            desc = "Flash";
          };
          action = # lua
            ''function() require("flash").toggle() end'';
          lua = true;
        }
        {
          mode = [
            "n"
            "x"
            "o"
          ];
          key = "s";
          options = {
            silent = true;
            desc = "Flash";
          };
          action = # lua
            ''function() require("flash").jump() end'';
          lua = true;
        }
        {
          mode = [
            "n"
            "x"
            "o"
          ];
          key = "S";
          options = {
            silent = true;
            desc = "Flash treesitter";
          };
          action = # lua
            ''function() require("flash").treesitter() end'';
          lua = true;
        }
        {
          mode = [
            "n"
            "x"
            "o"
          ];
          key = "<leader>sr";
          options = {
            silent = true;
            desc = "Flash resume";
          };
          action = # lua
            ''
              function()
                require("flash").jump({continue = true})
              end
            '';
          lua = true;
        }
        {
          mode = [
            "n"
            "x"
            "o"
          ];
          key = "<leader>sc";
          options = {
            silent = true;
            desc = "Flash current word";
          };
          action = # lua
            ''
              function()
                require("flash").jump({
                  pattern = vim.fn.expand("<cword>"),
                })
              end
            '';
          lua = true;
        }
        {
          mode = [
            "n"
            "x"
            "o"
          ];
          key = "<leader>sl";
          options = {
            silent = true;
            desc = "Flash line";
          };
          action = # lua
            ''
              function()
                require("flash").jump({
                  search = { mode = "search", max_length = 0 },
                  label = { after = { 0, 0 } },
                  pattern = "^"
                })
              end
            '';
          lua = true;
        }
        {
          mode = [
            "n"
            "x"
            "o"
          ];
          key = "<leader>sw";
          options = {
            silent = true;
            desc = "Flash word";
          };
          action = # lua
            ''
              function()
                require("flash").jump({
                  pattern = ".", -- initialize pattern with any char
                  search = {
                    mode = function(pattern)
                      -- remove leading dot
                      if pattern:sub(1, 1) == "." then
                        pattern = pattern:sub(2)
                      end
                      -- return word pattern and proper skip pattern
                      return ([[\<%s\w*\>]]):format(pattern), ([[\<%s]]):format(pattern)
                    end,
                  },
                  -- select the range
                  jump = { pos = "range" },
                })
              end
            '';
          lua = true;
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
  };
}
