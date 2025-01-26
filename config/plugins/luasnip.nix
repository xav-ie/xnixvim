_: {
  # useful code expansions
  # https://github.com/L3MON4D3/LuaSnip
  # https://nix-community.github.io/nixvim/plugins/luasnip
  config = {
    plugins.luasnip = {
      enable = true;
      lazyLoad.settings.event = "BufEnter";
      settings = {
        #   enable_autosnippets = true;
        #   store_selection_keys = “<Tab>”;
      };
      fromVscode = [ { } ];
    };
  };
}
