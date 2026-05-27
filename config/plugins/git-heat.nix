{ pkgs, lib, ... }:
let
  # crates.io's /api/v1/.../download now 403s curl's User-Agent (fetchurl uses
  # curl); rewrite those URLs to the CDN, which serves byte-identical tarballs
  # unblocked. The output hash is unchanged, so the lockfile checksums still hold.
  importCargoLock = pkgs.rustPlatform.importCargoLock.override {
    fetchurl =
      args:
      pkgs.fetchurl (
        args
        // lib.optionalAttrs (args ? url) {
          url = lib.replaceStrings [ "https://crates.io/api/v1/crates" ] [
            "https://static.crates.io/crates"
          ] args.url;
        }
      );
  };

  git-heat = pkgs.vimUtils.buildVimPlugin {
    name = "git-heat";
    # the churn/ subdir holds the Rust source for the binary below; it is
    # packaged separately and doesn't belong in the runtime vim plugin
    src = lib.cleanSourceWith {
      src = ../custom-plugins/git-heat;
      filter = path: type: !(type == "directory" && baseNameOf path == "churn");
    };
  };

  # per-line churn engine (gitoxide); replaces shelling out to `git log`
  git-heat-churn = pkgs.rustPlatform.buildRustPackage {
    pname = "git-heat-churn";
    version = "0.1.0";
    src = lib.cleanSourceWith {
      src = ../custom-plugins/git-heat/churn;
      # keep `target/` out of the source hash so local builds don't force rebuilds
      filter = path: type: !(type == "directory" && baseNameOf path == "target");
    };
    cargoDeps = importCargoLock { lockFile = ../custom-plugins/git-heat/churn/Cargo.lock; };
    meta.mainProgram = "git-heat-churn";
  };
in
{
  config = {
    extraConfigLua = ''require('git-heat').setup({ churn_bin = "${lib.getExe git-heat-churn}" })'';
    extraPlugins = [ git-heat ];
  };
}
