{ helpers, ... }:
{
  # FZF client
  # https://github.com/BenjaminTalbi/my-nixos/blob/a9c5d8ad7680bbfd7a6854cf2420870f2038bb00/home/nixvim/telescope.nix

  imports = [ ./telescope-symbols-nvim.nix ];

  config = {
    # Find, Filter, Preview, Pick.
    # https://github.com/nvim-telescope/telescope.nvim/
    # https://nix-community.github.io/nixvim/plugins/telescope
    plugins.telescope = {
      enable = true;
      settings = {
        defaults = {
          # see :h telescope.defaults.file_ignore_patterns
          # see https://www.lua.org/manual/5.1/manual.html#5.4.1 for pattern syntax
          file_ignore_patterns = [
            "%.generated%.d%.ts"
            "%.lock"
            "%.schema%.json"
            "^dist/"
            "package%-lock%.json"
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
          # emulate ivy default
          layout_strategy = "bottom_pane";
          layout_config.height = 0.5;
          sorting_strategy = "ascending";
        };
      };

      keymaps = {
        "<leader>fb" = {
          action = "buffers";
          options.desc = "[b]uffers";
        };
        "<leader>ff" = {
          action = "find_files";
          options.desc = "find_[f]iles";
        };
        "<leader>fi" = {
          action = "git_files";
          options.desc = "g[i]t_files";
        };
        "<leader>fj" = {
          action = "project";
          options.desc = "pro[j]ect";
        };
        "<leader>fk" = {
          action = "keymaps";
          options.desc = "[k]eymaps";
        };
        "<leader>fl" = {
          action = "live_grep";
          options.desc = "[l]ive_grep";
        };
        "<leader>fn" = {
          action = "manix";
          options.desc = "ma[n]ix";
        };
        "<leader>fo" = {
          action = "oldfiles";
          options.desc = "[o]ldfiles";
        };
        "<leader>fr" = {
          action = "resume";
          options.desc = "[r]esume Previous Seasch";
        };
        "<leader>fs" = {
          action = "spell_suggest";
          options.desc = "[s]pell_suggest";
        };
        "<leader>fu" = {
          action = "undo";
          options.desc = "[u]ndo";
        };
        "<leader>fg" = {
          action = "grep_string";
          options.desc = "[g]rep_string";
        };
      };

      extensions = {
        # faster fzf search
        fzf-native.enable = true;
        # nix documentation
        manix.enable = true;
        # project management
        project = {
          # breaks `nix flake check`
          enable = helpers.enableExceptInTests;
          settings = {
            base_dirs = [
              "~/Projects"
              "~/Work"
            ];
            # hidden_files = true;
            on_project_selected.__raw = ''
              function(prompt_bufnr)
                require("telescope._extensions.project.actions").change_working_directory(prompt_bufnr, false)
              end
            '';
          };
        };
        # replace native pickers with telescope
        ui-select.enable = true;
        # undo tree
        undo.enable = true;
      };
    };
  };
}
