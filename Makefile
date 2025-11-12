# dynamically resolve nom
nom := $(shell command -v nom || echo 'nix shell nixpkgs#nix-output-monitor --command nom')
dix := $(shell command -v dix || echo 'nix shell nixpkgs#dix --command dix')

.PHONY: build
build:
	@OLD_PATH=$$(readlink -f ./result 2>/dev/null || echo ""); \
	$(nom) build --no-write-lock-file; \
	if [ -n "$$OLD_PATH" ]; then \
		echo -e "\n=== Comparing derivations ===" && \
		$(dix) "$$OLD_PATH" ./result; \
	fi

.PHONY: check
check:
	nix flake check --no-write-lock-file

.PHONY: follow
follow:
	nix run github:fzakaria/nix-auto-follow -- -i

.PHONY: format
format:
	nix fmt --no-write-lock-file

.PHONY: update
update:
	$(MAKE) update-flake && $(MAKE) build

.PHONY: update-flake
update-flake:
	nix flake update && $(MAKE) follow

# Useful if you would not like this binary and dependencies garbage collected.
.PHONY: gc-root
gc-root:
	@mkdir -p /nix/var/nix/gcroots/per-user/$(USER)
	@ln -sfn $(PWD)/result /nix/var/nix/gcroots/per-user/$(USER)/xnixvim
	@echo "Created GC root: /nix/var/nix/gcroots/per-user/$(USER)/xnixvim -> $(PWD)/result"
