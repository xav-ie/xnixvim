{ pkgs, inputs, ... }:
{
  config = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "bgwinch.nvim";
        src = inputs.bgwinch;
        dependencies = [ pkgs.vimPlugins.plenary-nvim ];
      })
    ];

    extraConfigLua = ''
      -- Setup bgwinch with custom Linux dbus detection
      local Job = require('plenary.job')

      require('bgwinch').setup({
        set_bg = function()
          local Job = require "plenary.job"
          if vim.fn.has "mac" == 1 then
            local j = Job:new { command = "defaults", args = { "read", "-g", "AppleInterfaceStyle" } }
            j:sync()
            vim.o.background = j:result()[1] == "Dark" and "dark" or "light"
          elseif vim.fn.executable "dbus-send" == 1 then
            local j = Job:new {
              command = "dbus-send",
              args = {
                "--session",
                "--print-reply=literal",
                "--reply-timeout=1000",
                "--dest=org.freedesktop.portal.Desktop",
                "/org/freedesktop/portal/desktop",
                "org.freedesktop.portal.Settings.Read",
                "string:org.freedesktop.appearance",
                "string:color-scheme",
              },
            }
            j:sync()
            local result = table.concat(j:result(), " ")

            -- Parse dbus response: uint32 1 = dark, uint32 0/2 = light
            if string.match(result, "uint32 1") then
              vim.o.background = "dark"
            else
              vim.o.background = "light"
            end
          else
            vim.notify("dbus-send not found, cannot detect system theme", vim.log.levels.WARN)
          end
        end,
      })
    '';
  };
}
