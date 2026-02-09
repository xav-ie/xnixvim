{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.nixvim) defaultNullOpts;

  # Build the Go server component separately
  cursortab-server = pkgs.buildGoModule {
    pname = "cursortab-server";
    version = "unstable";
    src = "${inputs.cursortab-nvim}/server";
    vendorHash = "sha256-jarX9JbCICHDhwQk36AMR8DbtZtWfWYR+y42ZhP1rQ0=";
  };

  cursortab-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "cursortab.nvim";
    version = "unstable";
    src = inputs.cursortab-nvim;
    # Patch to use direct Nix store path for server binary
    # (nixvim bundles plugins into plugin-pack, losing the server/ directory)
    postPatch = ''
      substituteInPlace lua/cursortab/daemon.lua \
        --replace-fail 'local binary_path = plugin_dir .. "/server/" .. binary_name' \
                       'local binary_path = "${cursortab-server}/bin/cursortab"'
    '';
    nvimRequireCheck = [ "cursortab" ];
  };
  cfg = config.programs.cursortab;
in
{
  # AI Code Completion with cursor prediction
  # https://github.com/leonardcser/cursortab.nvim
  options.programs.cursortab = {
    enabled = lib.mkEnableOption "cursortab";
    settings = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enabled = defaultNullOpts.mkBool true "Enable the plugin";
          log_level = defaultNullOpts.mkEnum [
            "trace"
            "debug"
            "info"
            "warn"
            "error"
          ] "info" "Log level";
          state_dir = defaultNullOpts.mkStr null "Directory for runtime files (log, socket, pid)";

          keymaps = {
            accept = defaultNullOpts.mkStr "<Tab>" "Keymap to accept completion, or false to disable";
            partial_accept = defaultNullOpts.mkStr "<S-Tab>" "Keymap to partially accept";
            trigger = defaultNullOpts.mkStr null "Keymap to manually trigger completion";
          };

          ui = {
            colors = {
              deletion = defaultNullOpts.mkStr "#4f2f2f" "Background color for deletions";
              addition = defaultNullOpts.mkStr "#394f2f" "Background color for additions";
              modification = defaultNullOpts.mkStr "#282e38" "Background color for modifications";
              completion = defaultNullOpts.mkStr "#80899c" "Foreground color for completions";
            };
            jump = {
              symbol = defaultNullOpts.mkStr "" "Symbol shown for jump points";
              text = defaultNullOpts.mkStr " TAB " "Text displayed after jump symbol";
              show_distance = defaultNullOpts.mkBool true "Show line distance for off-screen jumps";
              bg_color = defaultNullOpts.mkStr "#373b45" "Jump text background color";
              fg_color = defaultNullOpts.mkStr "#bac1d1" "Jump text foreground color";
            };
          };

          behavior = {
            idle_completion_delay = defaultNullOpts.mkInt 50 "Delay in ms after idle to trigger completion (-1 to disable)";
            text_change_debounce = defaultNullOpts.mkInt 50 "Debounce in ms after text change to trigger completion (-1 to disable)";
            max_visible_lines = defaultNullOpts.mkInt 12 "Max visible lines per completion (0 to disable)";
            cursor_prediction = {
              enabled = defaultNullOpts.mkBool true "Show jump indicators after completions";
              auto_advance = defaultNullOpts.mkBool true "When no changes, show cursor jump to last line";
              proximity_threshold = defaultNullOpts.mkInt 2 "Min lines apart to show cursor jump (0 to disable)";
            };
          };

          provider = {
            type = defaultNullOpts.mkEnum [
              "inline"
              "fim"
              "sweep"
              "sweepapi"
              "zeta"
            ] "sweepapi" "Provider type";
            url = defaultNullOpts.mkStr "http://localhost:8000" "URL of the provider server";
            api_key_env = defaultNullOpts.mkStr "" "Env var name for API key";
            model = defaultNullOpts.mkStr "" "Model name";
            temperature = defaultNullOpts.mkFloat 0.0 "Sampling temperature";
            max_tokens = defaultNullOpts.mkInt 512 "Max tokens to generate";
            top_k = defaultNullOpts.mkInt 50 "Top-k sampling";
            completion_timeout = defaultNullOpts.mkInt 5000 "Timeout in ms for completion requests";
            max_diff_history_tokens = defaultNullOpts.mkInt 512 "Max tokens for diff history (0 = no limit)";
            completion_path = defaultNullOpts.mkStr "/v1/completions" "API endpoint path";
            fim_tokens = {
              prefix = defaultNullOpts.mkStr "<|fim_prefix|>" "FIM prefix token";
              suffix = defaultNullOpts.mkStr "<|fim_suffix|>" "FIM suffix token";
              middle = defaultNullOpts.mkStr "<|fim_middle|>" "FIM middle token";
            };
            privacy_mode = defaultNullOpts.mkBool true "Don't send telemetry to provider";
          };

          blink = {
            enabled = defaultNullOpts.mkBool false "Enable blink source";
            ghost_text = defaultNullOpts.mkBool true "Show native ghost text alongside blink menu";
          };

          debug = {
            immediate_shutdown = defaultNullOpts.mkBool false "Shutdown daemon immediately when no clients";
          };
        };
      };
    };
  };

  # my config - using local vLLM with Sweep model
  config.programs.cursortab.settings = {
    enabled = true;
    log_level = "info";

    keymaps = {
      accept = "<Tab>";
      partial_accept = "<S-Tab>";
      trigger = "<C-y>"; # Manually trigger completion
    };

    provider = {
      type = "sweep";
      url = "https://vllm.lalala.casa";
    };

    ui = {
      jump = {
        show_distance = true;
      };
    };

    behavior = {
      idle_completion_delay = 50;
      text_change_debounce = 50;
    };
  };

  config.extraPlugins = lib.optional cfg.enabled {
    plugin = cursortab-nvim;
    optional = true;
  };

  config.plugins.lz-n.plugins = lib.optional cfg.enabled {
    "__unkeyed-1" = "cursortab.nvim";
    event = [ "InsertEnter" ];
    after = # lua
      ''
        function()
          require'cursortab'.setup ${lib.nixvim.toLuaObject cfg.settings}
        end
      '';
  };
}
