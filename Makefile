# dynamically resolve nom
nom := $(shell command -v nom || echo 'nix shell nixpkgs#nix-output-monitor --command nom')

.PHONY: build
build:
	$(nom) build --no-write-lock-file

.PHONY: check
check:
	nix flake check --no-write-lock-file

.PHONY: format
format:
	nix fmt

.PHONY: update
update:
	nix flake update && nix run github:fzakaria/nix-auto-follow -- -i
