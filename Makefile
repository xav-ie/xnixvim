build:
	NIXPKGS_ALLOW_UNFREE=1 nix run nixpkgs#nix-output-monitor -- build --impure

check:
	NIXPKGS_ALLOW_UNFREE=1 nix flake check --impure

format:
	NIXPKGS_ALLOW_UNFREE=1 nix fmt
