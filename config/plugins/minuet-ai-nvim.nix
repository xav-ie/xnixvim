{ pkgs, inputs, ... }:
let
  minuet-ai-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "minuet-ai.nvim";
    src = inputs.minuet-ai-nvim;
    dependencies = with pkgs.vimPlugins; [
      # TODO: add dependencies if you use the cmp
      # or blink extensions only
      # nvim-cmp
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
          virtualtext = {
            auto_trigger_ft = { '*' },
            keymap = {
              accept = '<Tab>',
              accept_line = '<A-a>',
              --  TODO: better bindings
              prev = '<C-Left>',
              next = '<C-Right>',
              dismiss = '<A-e>',
            },
          },
          provider = 'openai_fim_compatible',
          provider_options = {
            openai_fim_compatible = {
              model = 'deepseek-chat',
              end_point = 'https://api.deepseek.com/beta/completions',
              api_key = 'DEEPSEEK_API_KEY',
              name = 'Deepseek',
              stream = true,
              optional = {
                -- top_p = 0.9,
                stop = nil,
                max_tokens = nil,
              },
            }
          },
        }
      '';

    extraPlugins = [ minuet-ai-nvim ];
  };
}
