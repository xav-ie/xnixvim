{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.nixvim) defaultNullOpts;
  minuet-ai-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "minuet-ai.nvim";
    src = inputs.minuet-ai-nvim;
    dependencies = with pkgs.vimPlugins; [
      # TODO: add dependencies if you use the cmp
      # or blink extensions only
      nvim-cmp
      nvim-treesitter
      plenary-nvim
    ];
    nvimRequireCheck = [
      "minuet"
      "minuet.backends.common"
      "minuet.blink"
      # TODO: configure cmp?
      # "minuet.cmp"
      "minuet.config"
      "minuet.utils"
      "minuet.virtualtext"
    ];
  };
  cfg = config.programs.minuet-ai;
in
{
  # AI Code Completion
  # https://github.com/milanglacier/minuet-ai.nvim
  options.programs.minuet-ai = {
    enabled = lib.mkEnableOption "minuet-ai";
    settings = lib.mkOption {
      type = lib.types.submodule {
        options =
          let
            # https://github.com/milanglacier/minuet-ai.nvim/blob/9a264284573b837dc0202049166a0564a70deaed/lua/minuet/modelcard.lua
            providers = [
              "claude"
              "codestral"
              "gemini"
              "huggingface"
              "openai"
              "openai_compatible"
              "openai_fim_compatible"
              # definitely more providers to be added here...
            ];

            providerOptionsOption = {
              api_key = defaultNullOpts.mkStr null "API key to use for the model";
              end_point = defaultNullOpts.mkStr' {
                pluginDefault = null;
                example = "http://localhost:11434/v1/completions";
                description = "API end point URL";
              };
              model = defaultNullOpts.mkStr' {
                pluginDefault = null;
                example = "qwen2.5-coder:0.5b";
                description = "The model to use";
              };
              name = defaultNullOpts.mkStr' {
                pluginDefault = null;
                example = "Ollama";
                description = "The model appearance name";
              };
              stream = defaultNullOpts.mkBool false "Whether the model supports streaming output";
              optional = {
                stop = defaultNullOpts.mkStr' {
                  pluginDefault = null;
                  example = "\n\n";
                  description = "stop token";
                };
                max_tokens = defaultNullOpts.mkInt' {
                  pluginDefault = null;
                  example = 256;
                  description = "max tokens to generate";
                };
                # there is definitely more options I don't know about...
              };
            };
          in
          {
            cmp = {
              auto_trigger_ft =
                defaultNullOpts.mkListOf lib.types.str [ ]
                  "The list of file types to auto-trigger";
              enable_auto_complete = defaultNullOpts.mkBool true "Whether to enable auto-complete";
            };
            blink = {
              enable_auto_complete = defaultNullOpts.mkBool true "Whether to enable auto-complete";
            };
            provider = defaultNullOpts.mkEnum providers "codestral" "The provider to use";
            context_window = defaultNullOpts.mkInt 16000 ''
              the maximum total characters of the context before and after the cursor
              16000 characters typically equate to approximately 4,000 tokens for
              LLMs.
            '';
            context_ratio = defaultNullOpts.mkFloat 0.75 ''
              when the total characters exceed the context window, the ratio of
              context before cursor and after cursor, the larger the ratio the more
              context before cursor will be used. This option should be between 0 and
              1, context_ratio = 0.75 means the ratio will be 3:1.
            '';
            throttle = defaultNullOpts.mkInt 1000 ''
              only send the request every x milliseconds, use 0 to disable throttle.
            '';
            debounce = defaultNullOpts.mkInt 400 ''
              debounce the request in x milliseconds, set to 0 to disable debounce
            '';
            notify = defaultNullOpts.mkEnum [
              "debug"
              "verbose"
              "warn"
              "error"
              false
            ] "warn" "The notification message";
            request_timeout = defaultNullOpts.mkInt 3 ''
              The request timeout, measured in seconds. When streaming is enabled
              (stream = true), setting a shorter request_timeout allows for faster
              retrieval of completion items, albeit potentially incomplete.
              Conversely, with streaming disabled (stream = false), a timeout
              occurring before the LLM returns results will yield no completion items.
            '';
            add_single_line_entry = defaultNullOpts.mkBool true ''
              If completion item has multiple lines, create another completion item
              only containing its first line. This option only has impact for cmp and
              blink. For virtualtext, no single line entry will be added.
            '';
            n_completions = defaultNullOpts.mkInt 3 ''
              The number of completion items encoded as part of the prompt for the
              chat LLM. For FIM model, this is the number of requests to send. It's
              important to note that when 'add_single_line_entry' is set to true, the
              actual number of returned items may exceed this value. Additionally, the
              LLM cannot guarantee the exact number of completion items specified, as
              this parameter serves only as a prompt guideline.
            '';
            after_cursor_filter_length = defaultNullOpts.mkInt 15 ''
              Defines the length of non-whitespace context after the cursor used to
              filter completion text. Set to 0 to disable filtering.

              Example: With after_cursor_filter_length = 3 and context:

              "def fib(n):\n|\n\nfib(5)" (where | represents cursor position),

              if the completion text contains "fib", then "fib" and subsequent text
              will be removed. This setting filters repeated text generated by the
              LLM. A large value (e.g., 15) is recommended to avoid false positives.
            '';
            proxy = defaultNullOpts.mkStr null "Proxy port to use";

            provider_options = lib.listToAttrs (
              map (provider: {
                # Dynamically create the provider options
                name = provider;
                value = providerOptionsOption;
              }) providers
            );
          };
      };
    };
  };

  # my config
  config.programs.minuet-ai = {
    enabled = true;
    settings = {
      # notify = "verbose";
      # provider = "openai_fim_compatible";
      provider = "codestral";
      context_window = 1000;
      # no need to throttle on local connections
      throttle = if cfg.settings.provider == "openai_fim_compatible" then 0 else null;
      debounce = if cfg.settings.provider == "openai_fim_compatible" then 0 else null;
      n_completions = if cfg.settings.provider == "openai_fim_compatible" then 3 else 1;

      cmp = {
        auto_trigger_ft = [ "*" ];
        enable_auto_complete = true;
      };

      provider_options = {
        openai_fim_compatible = {
          api_key = "TERM";
          end_point = "http://localhost:11434/v1/completions";
          model = "qwen2.5-coder:0.5b";
          name = "Ollama";
          stream = true;
          optional = {
            max_tokens = 25;
          };
        };
        codestral = {
          api_key = "CODESTRAL_API_KEY";
          end_point = "https://codestral.mistral.ai/v1/fim/completions";
          model = "codestral-latest";
          stream = true;
          optional = {
            stop = "\n\n";
            max_tokens = 25;
          };
        };
      };
    };
  };

  config.extraConfigLua =
    lib.optionalString cfg.enabled # lua
      ''
        require'minuet'.setup ${lib.nixvim.toLuaObject cfg.settings}
      '';

  config.extraPlugins = lib.optional cfg.enabled minuet-ai-nvim;
}
