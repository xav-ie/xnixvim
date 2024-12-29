.PHONY: build
build:
	nix run nixpkgs#nix-output-monitor -- build --no-write-lock-file

.PHONY: check
check:
	nix flake check --no-write-lock-file

.PHONY: format
format:
	nix fmt

.PHONY: update
update:
	nix flake update && nix run github:fzakaria/nix-auto-follow -- -i
