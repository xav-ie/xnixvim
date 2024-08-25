build:
	nix run nixpkgs#nix-output-monitor -- build

check:
	nix flake check

format:
	nix fmt
