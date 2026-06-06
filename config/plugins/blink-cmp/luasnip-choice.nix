{
  config,
  lib,
  ...
}:
# blink.cmp ⇄ LuaSnip bridge: surface an active choiceNode's options in the
# completion menu — a blink-native port of L3MON4D3/cmp-luasnip-choice. The Lua
# source module lives alongside this file in ./luasnip-choice.lua.
{
  config = lib.mkIf config.plugins.blink-cmp.enable {
    # Register the source provider. Deliberately kept out of `sources.default`
    # (see ./default.nix): it's triggered only by the autocmd below, via
    # blink.show({ providers = { "luasnip_choice" } }).
    plugins.blink-cmp.settings.sources.providers.luasnip_choice = {
      name = "Choice";
      module = "blink_luasnip_choice";
    };

    # Drop the provider's module onto the runtime path so the `module` string
    # above resolves to a require()-able Lua file.
    extraFiles."lua/blink_luasnip_choice.lua".source = ./luasnip-choice.lua;

    # When LuaSnip enters a choiceNode, pop blink's menu showing just that
    # node's options. require()s are deferred into the callback so neither
    # lazy-loaded plugin is forced to load early.
    extraConfigLua = # lua
      ''
        vim.api.nvim_create_autocmd("User", {
          pattern = "LuasnipChoiceNodeEnter",
          desc = "Show LuaSnip choices in the blink completion menu",
          callback = function()
            vim.schedule(function()
              local ok, blink = pcall(require, "blink.cmp")
              if ok then
                blink.show({ providers = { "luasnip_choice" } })
              end
            end)
          end,
        })
      '';
  };
}
