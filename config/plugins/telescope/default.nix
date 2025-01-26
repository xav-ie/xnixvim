{
  config,
  helpers,
  lib,
  ...
}:
{
  imports = [ ./telescope-symbols-nvim.nix ];

  # Find, Filter, Preview, Pick.
  # https://github.com/nvim-telescope/telescope.nvim/
  # https://nix-community.github.io/nixvim/plugins/telescope
  config =
    # inherit modeKeys;
    let
      modeKeys = import ../../modeKeys.nix { inherit lib; };
    in
    {
      plugins.telescope = {
        enable = true;
        lazyLoad.settings.cmd = "Telescope";
        lazyLoad.enable = config.lazyLoad.enable;
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
              "*.lock"
              "package-lock.json"
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
          "<leader>fb" = {
            action = "buffers";
            options.desc = "[b]uffers";
          };
          "<leader>fi" = {
            action = "git_files";
            options.desc = "g[i]t_files";
          };
          "<leader>fk" = {
            action = "keymaps";
            options.desc = "[k]eymaps";
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
          # replace native pickers with telescope
          ui-select.enable = true;
          undo = {
            enable = true;
          };
        };
      };

      keymaps = helpers.keymaps.mkKeymaps { options.silent = true; } (
        modeKeys.nm {
          # less noisy dropdown
          "<leader>ff" = {
            # TODO: make a PR to nixvim to enable raw option within telescope keymaps attribute
            action.__raw = # lua
              "function() require('telescope.builtin').find_files(require('telescope.themes').get_dropdown({ previewer = false })) end";
            options.desc = "find_[f]iles";
          };
        }
      );
    };
}
