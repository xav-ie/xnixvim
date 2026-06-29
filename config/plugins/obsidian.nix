{ config, lib, ... }:
let
  modeKeys = import ../modeKeys.nix { inherit lib; };
in
{
  # write & navigate an Obsidian vault from neovim
  # https://github.com/obsidian-nvim/obsidian.nvim
  # https://nix-community.github.io/nixvim/plugins/obsidian
  config = {
    plugins.obsidian = {
      enable = true;
      # Load when a markdown buffer opens, or when an `:Obsidian …` command is
      # invoked (so the leader keymaps below pull the plugin in on first use).
      lazyLoad.enable = config.lazyLoad.enable;
      lazyLoad.settings = {
        ft = "markdown";
        cmd = "Obsidian";
        # obsidian registers its completion providers via `require("blink.cmp")`
        # the moment its setup runs, but blink-cmp is lazy (InsertEnter) and so
        # isn't on the runtimepath on a markdown BufRead — that require fails.
        # Force blink to load first; it pulls in its own colorful-menu dependency
        # via its `before` hook (see blink-cmp/default.nix).
        before.__raw = ''
          function()
            require("lz.n").trigger_load("blink.cmp")
          end
        '';
      };

      settings = {
        workspaces = [
          {
            name = "Notes";
            path = "~/Notes";
          }
        ];

        # Put new notes next to the file you're editing rather than a notes dir.
        new_notes_location = "current_dir";

        # Use the modern `:Obsidian <subcommand>` form exclusively (the keymaps
        # below already do). Disables the deprecated `:ObsidianXxx` commands and
        # their startup warning.
        legacy_commands = false;

        # Native blink.cmp completion. obsidian injects its `obsidian` /
        # `obsidian_tags` (+ `obsidian_new`) providers into blink's
        # `sources.default` list the first time a markdown buffer in the
        # workspace is opened — no manual source wiring needed here.
        completion = {
          blink = true;
          nvim_cmp = false;
          min_chars = 2;
        };

        # Use obsidian's own UI (concealed links, checkboxes, refs). This
        # overlaps with markview.nvim on markdown buffers — see ./markview.nix.
        ui.enable = true;

        # Daily notes live in ~/Notes/daily/, named YYYY-MM-DD.md, scaffolded
        # from templates/daily.md. `:Obsidian today` (<leader>Ot) opens today's.
        daily_notes = {
          folder = "daily";
          date_format = "YYYY-MM-DD";
          template = "daily.md";
        };

        # Template files live in ~/Notes/templates/. {{date}}/{{title}} etc. are
        # substituted on insertion (moment.js tokens; see templates/daily.md).
        templates = {
          folder = "templates";
          date_format = "YYYY-MM-DD";
          time_format = "HH:mm";
        };

        # Drive :Obsidian search / quick_switch / etc. through telescope (already
        # this config's picker) instead of the built-in mini picker.
        picker.name = "telescope.nvim";

        # Prefer wiki links ([[note]]) for newly inserted links — typing `[[`
        # fires the obsidian blink source for fuzzy note completion. Existing
        # markdown-style links still resolve; this only affects new ones.
        link.style = "wiki";

        # Clean, title-based filenames for `:Obsidian new` (e.g. "my-idea.md")
        # instead of the default Zettelkasten timestamp ids (e.g. "1782762183-LZNG").
        note_id_func.__raw = ''
          function(title)
            if title ~= nil then
              return title:gsub("%s+", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
            end
            return tostring(os.time())
          end
        '';
        # External URL following uses vim.ui.open by default now — no
        # follow_url_func needed (it's deprecated as of obsidian.nvim 3.18).
      };
    };

    # All keymaps go through `:Obsidian …`, which also triggers the lazy load.
    keymaps = lib.mkIf config.plugins.obsidian.enable (
      lib.nixvim.keymaps.mkKeymaps { options.silent = true; } (
        modeKeys.nm {
          "<leader>Oo" = {
            action = "<cmd>Obsidian quick_switch<CR>";
            options.desc = "[O]bsidian [o]pen / switch note";
          };
          "<leader>On" = {
            action = "<cmd>Obsidian new<CR>";
            options.desc = "[O]bsidian [n]ew note";
          };
          "<leader>Om" = {
            action = "<cmd>Obsidian new_from_template<CR>";
            options.desc = "[O]bsidian new from te[m]plate";
          };
          "<leader>Os" = {
            action = "<cmd>Obsidian search<CR>";
            options.desc = "[O]bsidian [s]earch";
          };
          "<leader>Ot" = {
            action = "<cmd>Obsidian today<CR>";
            options.desc = "[O]bsidian [t]oday's daily note";
          };
          "<leader>Ob" = {
            action = "<cmd>Obsidian backlinks<CR>";
            options.desc = "[O]bsidian [b]acklinks";
          };
          "<leader>Og" = {
            action = "<cmd>Obsidian tags<CR>";
            options.desc = "[O]bsidian ta[g]s";
          };
          "<leader>Oc" = {
            action = "<cmd>Obsidian toggle_checkbox<CR>";
            options.desc = "[O]bsidian toggle [c]heckbox";
          };
        }
      )
    );

    # obsidian's UI only renders concealed links/refs when conceallevel >= 1.
    # Set it per markdown buffer instead of globally (a global conceallevel
    # would hide syntax in code buffers too).
    extraConfigLua =
      lib.mkIf config.plugins.obsidian.enable # lua
        ''
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "markdown",
            callback = function()
              vim.opt_local.conceallevel = 2
            end,
          })
        '';
  };
}
