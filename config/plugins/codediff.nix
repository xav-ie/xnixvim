{
  pkgs,
  inputs,
  ...
}:
let
  libExt = if pkgs.stdenv.hostPlatform.isDarwin then "dylib" else "so";

  # VSCode-style diff renderer with two-tier (line + character) highlighting,
  # side-by-side and inline layouts, moved-block detection, and a Neogit
  # diff_viewer integration.
  # https://github.com/esmuellert/codediff.nvim
  #
  # Notes for the Nix build:
  # - The plugin's runtime auto-installer downloads a prebuilt
  #   libvscode_diff.{dylib,so,dll} into the plugin directory. That dir is a
  #   read-only /nix/store path here, so we build the native library
  #   ourselves via CMake at derivation time.
  # - codediff's loader (lua/codediff/core/diff.lua) looks for
  #   libvscode_diff_<VERSION>.<ext> next to the plugin root, with an
  #   unversioned fallback. We install with the versioned name so it
  #   shortcircuits the auto-installer entirely.
  codediff-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "codediff.nvim";
    version = "unstable";
    src = inputs.codediff-nvim;

    nativeBuildInputs = [ pkgs.cmake ];
    # We drive cmake manually so it runs from preInstall (after the vim plugin
    # source has been laid out for installPhase).
    dontUseCmakeConfigure = true;

    preInstall = ''
      cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
      cmake --build build --parallel $NIX_BUILD_CORES
    '';

    postInstall = ''
      version=$(cat VERSION)
      built=$(find build -name "libvscode_diff.${libExt}" -print -quit)
      if [ -z "$built" ]; then
        echo "codediff: libvscode_diff.${libExt} not produced by cmake" >&2
        exit 1
      fi
      install -Dm644 "$built" "$out/libvscode_diff_$version.${libExt}"
    '';

    doCheck = false;
  };
in
{
  config = {
    extraPlugins = [ codediff-nvim ];

    extraConfigLua = # lua
      ''
        require('codediff').setup({
          -- TODO(human)
        })
      '';
  };
}
