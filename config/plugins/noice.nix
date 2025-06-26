{ config, ... }:
{
  # replace nvim ui with nicer one
  # https://github.com/folke/noice.nvim
  # https://nix-community.github.io/nixvim/plugins/noice
  config = {
    plugins.noice = {
      enable = true;
      lazyLoad.settings.event = "BufEnter";
      lazyLoad.enable = config.lazyLoad.enable;
      settings = {
        messages = {
          view = "mini"; # too many info notifications...very annoying!
          # I think these two are good candidates for notifications:
          viewError = "notify";
          viewWarn = "notify";
        };
        lsp = {
          # suppress "No information available." bug
          hover.silent = true;
          override = {
            "vim.lsp.util.convert_input_to_markdown_lines" = true;
            "vim.lsp.util.stylize_markdown" = true;
            "cmp.entry.get_documentation" = true;
          };
        };
        # faulty checks
        health.checker = false;

        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
          inc_rename = true;
          lsp_doc_border = true;
        };
      };
    };
  };
}
