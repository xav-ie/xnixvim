{ config, ... }:
{
  config = {
    # https://nix-community.github.io/nixvim/plugins/markview
    # https://github.com/OXY2DEV/markview.nvim
    plugins.markview = {
      enable = true;
      lazyLoad.settings.ft = "markdown";
      lazyLoad.enable = config.lazyLoad.enable;
      settings = {
        preview = {
          icon_provider = "devicons";
        };
        markdown = {
          headings = {
            heading_1 = {
              sign = "";
              icon = "󰼏 ";
            };
            heading_2 = {
              sign = "";
              icon = "󰎨 ";
            };
            heading_3.icon = "󰼑 ";
            heading_4.icon = "󰎲 ";
            heading_5.icon = "󰼓 ";
            heading_6.icon = "󰎴 ";
          };
          code_blocks.sign = false;
          # Keep raw and rendered column geometry in sync.
          # - conceal_on_checkboxes=false: keep literal `- ` visible so the
          #   icon sits where `[ ]` is in source (col 2), not col 0.
          # - add_padding=false: markview otherwise injects
          #   `(indent/indent_size + 1) * shift_width` leading spaces per
          #   list line (4 cells at the top level), which don't exist in
          #   source and push everything right in normal mode.
          list_items = {
            marker_minus = {
              conceal_on_checkboxes = false;
              add_padding = false;
            };
            marker_plus = {
              conceal_on_checkboxes = false;
              add_padding = false;
            };
            marker_star = {
              conceal_on_checkboxes = false;
              add_padding = false;
            };
            marker_dot.add_padding = false;
            marker_parenthesis.add_padding = false;
          };
        };
        markdown_inline = {
          checkboxes = {
            checked.text = " 󰗠 ";
            unchecked.text = " 󰄰 ";
          };
        };
      };
    };
    # Markdown heading / code / bullet colors live in the xdusk colorscheme
    # (custom-plugins/xdusk) — see the Markview* groups there.
  };
}
