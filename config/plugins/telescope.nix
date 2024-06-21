{ ... }:
{
  # FZF client
  # https://github.com/BenjaminTalbi/nixos-configurations/blob/0f160eaa0eae5a0417bc3eafae5e5e389614bda2/home/nixvim/telescope.nix
  plugins.telescope = {
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
}