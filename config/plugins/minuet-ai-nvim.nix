{ pkgs, inputs, ... }:
let
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
in
{
  # TODO: add specific dep on nix binary

  # AI Code Completion
  # https://github.com/milanglacier/minuet-ai.nvim
  config = {
    extraConfigLua = # lua
      ''
        require'minuet'.setup {
          -- virtualtext = {
          --   auto_trigger_ft = { '*' },
          --   keymap = {
          --     accept = '<Tab>',
          --     accept_line = '<A-a>',
          --     --  TODO: better bindings
          --     prev = '<C-Left>',
          --     next = '<C-Right>',
          --     dismiss = '<A-e>',
          --   },
          -- },
          cmp = {
            auto_trigger_ft = { '*' },
            enable_auto_complete = true,
          },
          provider = 'openai_fim_compatible',
          provider_options = {
            openai_fim_compatible = {
              api_key = 'DEEPSEEK_API_KEY',
              end_point = 'https://api.deepseek.com/beta/completions',
              model = 'deepseek-chat',
              name = 'Deepseek',
              stream = true,
              optional = {
                -- top_p = 0.9,
                stop = nil,
                max_tokens = nil,
              },
            },
            -- openai_fim_compatible = {
            --   api_key = 'TERM',
            --   end_point = 'http://localhost:11434/v1/completions',
            --   model = 'qwen2.5-coder:0.5b',
            --   name = 'Ollama',
            --   stream = true,
            --   optional = {
            --     stop = nil,
            --     max_tokens = nil,
            --   },
            -- },
            -- openai_compatible = {
            --   api_key = 'FIREWORKS_API_KEY',
            --   end_point = 'https://api.fireworks.ai/inference/v1/chat/completions',
            --   model = 'accounts/fireworks/models/llama-v3p3-70b-instruct',
            --   name = 'Fireworks',
            --   optional = {
            --     max_tokens = 256,
            --     top_p = 0.9,
            --   },
            -- },

          },
        }
      '';

    extraPlugins = [ minuet-ai-nvim ];
  };
}
