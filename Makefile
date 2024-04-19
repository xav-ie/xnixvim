build:
	NIXPKGS_ALLOW_UNFREE=1 nix run nixpkgs#nix-output-monitor -- build --impure

