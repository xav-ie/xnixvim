{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  himalaya-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "himalaya-nvim";
    version = "unstable-2026-02-16";
    src = inputs.himalaya-nvim;
  };

in
{
  config = lib.mkIf pkgs.stdenv.isLinux {
    extraPlugins = [ himalaya-nvim ];

    extraPackages = [ pkgs.himalaya ];

    # Defer setup() off the critical path: the :Himalaya command is registered
    # by the plugin source itself, so configuration only needs to be in place
    # before the mailbox is first opened. ~1.8ms of requires saved at startup.
    extraConfigLua = ''
      vim.api.nvim_create_autocmd('User', {
        pattern = 'DeferredUIEnter',
        once = true,
        callback = function()
      require('himalaya').setup({
        folder_picker = 'telescope',
        telescope_preview = false,
        flags = {
          header = '\xef\x80\xa4 ',
          -- flagged = '\xf3\xb0\x88\xbf',
          flagged = false,
          unseen = false,
          answered = '\xef\x84\x92 ',
          attachment = '\xef\x83\x86 ',
        },
        gutters = false,
        date_format = '%m/%d %H',
        thread_view = true,
        thread_reverse = true,
        reading_split = {
          threshold = 95,
          under = { side = 'above', size = 0.7 },
          over = { side = 'right', size = 70 },
        },
        compact_flags = 'always',
        compact_ids = 'always',
        -- Progressive (two-pass) image rendering: paint a first image as soon
        -- as the DOM is interactive, then re-render once the page completes.
        -- Off by default in himalaya-nvim; opt in here. Set false / remove to
        -- go back to a single capture once the page is complete (or load cap).
        render_html = {
          -- Render emails as images by default (gI toggles back to text).
          image_mode = true,
          -- Emulate prefers-color-scheme: dark so emails render their own dark
          -- theme instead of blinding white.
          dark = true,
          progressive = true,
          -- Capture supersample factor (sharpness only — see zoom for size).
          -- The capture is taken at this scale and downscaled to the display
          -- width, so 2 gives crisp HiDPI text without affecting how large the
          -- content is laid out.
          device_scale_factor = 2,
          -- Content zoom (%). Controls the CSS width the email lays out at,
          -- hence how large it appears in the fixed display area. 100 = lay out
          -- at the true display width (faithful desktop proportions). Bump >100
          -- to magnify, drop <100 to fit wider emails.
          zoom = 150,
          -- Chunked rendering: slice the tall email PNG into viewport-height
          -- tiles, each its own image.nvim image. image.nvim only transmits the
          -- tiles intersecting the visible window, so a long email paints ~1
          -- screen up front and streams the rest on scroll. Set false to go
          -- back to one image for the whole email.
          chunked = true,
          -- Unicode-placeholder rendering: image transmitted once as a virtual
          -- placement, laid out as buffer-text placeholder cells that scroll in
          -- lockstep with the grid — fully smooth, no seam flicker. Takes
          -- precedence over chunked. Set false to fall back to chunked crop.
          placeholders = true,
          -- Smooth scroll is safe to keep on now — placeholders don't flicker.
          smooth_image_scroll = true,
          -- Hybrid text/image layer (experimental, Phase 0). Extracts the email's
          -- links + bounding boxes and maps them onto the placeholder cells.
          -- :HimalayaHybridDots toggles alignment markers over the image;
          -- :HimalayaHybridDump lists the entities. Set false to disable.
          hybrid = true,
        },
      })
        end,
      })
    '';
  };
}
