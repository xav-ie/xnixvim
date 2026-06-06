{ config, pkgs, ... }:
let
  # Tier-3 fallback toolchain for Rust files opened with no project toolchain
  # (loose files, un-set-up clones). A bundled rust-analyzer alone is useless —
  # it shells out to cargo/rustc — so the wrapper puts the whole nixpkgs
  # toolchain on PATH and points RUST_SRC_PATH at the std-library source for
  # go-to-definition. NOT added to Neovim's global PATH on purpose: that would
  # make the `cargo` probe below always true and defeat the in-env fast path.
  rustFallback = pkgs.writeShellScript "rust-analyzer-fallback" ''
    export PATH="${pkgs.cargo}/bin:${pkgs.rustc}/bin:${pkgs.rust-analyzer}/bin:$PATH"
    export RUST_SRC_PATH="${pkgs.rustPlatform.rustLibSrc}"
    exec "${pkgs.rust-analyzer}/bin/rust-analyzer" "$@"
  '';
in
{
  # Rust dev plugin (successor to rust-tools). Manages the rust-analyzer client
  # itself — do NOT also enable plugins.lsp.servers.rust_analyzer — and adds
  # `:RustLsp` commands (runnables, expandMacro, openCargo, ...).
  # https://github.com/mrcjkb/rustaceanvim
  # https://nix-community.github.io/nixvim/plugins/rustaceanvim
  config = {
    plugins.rustaceanvim = {
      enable = true;
      lazyLoad.enable = config.lazyLoad.enable;
      lazyLoad.settings.ft = "rust";

      # Written verbatim to vim.g.rustaceanvim.
      settings = {
        # rust-analyzer shells out to cargo/rustc, so it needs a toolchain on its
        # PATH — not just the right rust-analyzer binary. Three tiers:
        #   1. in-env (cargo on PATH, e.g. nvim launched from the devenv/direnv
        #      shell) → start directly, instant.
        #   2. project has a .envrc but env isn't loaded → launch through
        #      `direnv exec <root>` to pull in the project's toolchain (costs a
        #      one-time devenv eval).
        #   3. no project toolchain at all → the bundled nixpkgs fallback.
        server.cmd.__raw = # lua
          ''
            function()
              if vim.fn.executable("cargo") == 1 then
                return { "rust-analyzer" }
              end
              local root = vim.fs.root(0, { "Cargo.toml", ".envrc", ".git" }) or vim.fn.getcwd()
              if vim.fn.executable("direnv") == 1 and vim.uv.fs_stat(root .. "/.envrc") then
                return { "direnv", "exec", root, "rust-analyzer" }
              end
              return { "${rustFallback}" }
            end
          '';
        server.default_settings.rust-analyzer = {
          # clippy on save instead of plain `cargo check`.
          check.command = "clippy";

          cargo.buildScripts.enable = true;
          # cargo.allFeatures = true; # breaks workspaces with exclusive features

          procMacro.enable = true;

          files = {
            # Let Neovim do the file-watching (selective globs it registers)
            # instead of rust-analyzer recursively FSEvents-watching every root.
            # Server-side watching on macOS spins at ~95% CPU in getattrlist over
            # the immutable nix-store sysroot + build/cache dirs (a sample showed
            # the time is all in fs stat + notify-rs threads, not analysis).
            watcher = "client";
            # Don't load/scan these into the VFS at all: build artifacts and the
            # devenv/direnv state trees are enormous and never contain sources.
            excludeDirs = [
              "target"
              "result"
              ".direnv"
              ".devenv"
              ".git"
            ];
          };

          inlayHints = {
            bindingModeHints.enable = true;
            closureReturnTypeHints.enable = "with_block";
            lifetimeElisionHints = {
              enable = "skip_trivial";
              useParameterNames = true;
            };
          };
        };
      };
    };
  };
}
