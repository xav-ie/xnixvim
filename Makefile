build:
	nix run nixpkgs#nix-output-monitor -- build --no-write-lock-file

check:
	nix flake check --no-write-lock-file

format:
	nix fmt

update:
	nix flake update && nix run github:fzakaria/nix-auto-follow -- -i
