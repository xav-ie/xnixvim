MAKEFLAGS += --no-print-directory

nom := $(shell command -v nom || \
	echo 'nix shell nixpkgs#nix-output-monitor --command nom')
dix := $(shell command -v dix || echo 'nix shell nixpkgs#dix --command dix')
auto-follow := $(shell command -v auto-follow || \
	echo 'nix shell github:xav-ie/nix-auto-follow/feat-consolidation --command auto-follow')
gc_root_dir := /nix/var/nix/gcroots/per-user/$(USER)

.PHONY: default
default:
	@$(MAKE) gc-root-devshell-start
	@$(MAKE) build
	@$(MAKE) gc-root
	@$(MAKE) gc-root-devshell-cleanup

.PHONY: build
build:
	@OLD_PATH=$$(readlink -f ./result 2>/dev/null || echo ""); \
	$(nom) build --option access-tokens "github.com=$(gh auth token)"; \
	if [ -n "$$OLD_PATH" ]; then \
		echo -e "\n=== Comparing derivations ===" && \
		$(dix) "$$OLD_PATH" ./result; \
	fi

.PHONY: check
check:
	nix flake check --no-write-lock-file

.PHONY: follow
follow:
	$(auto-follow) -i

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
	@mkdir -p $(gc_root_dir)
	@ln -sfn $(PWD)/result $(gc_root_dir)/xnixvim

gc_root_name := result-xnixvim-devshell

# Start devShell build in background (removes out-link first so cleanup can
# detect completion)
.PHONY: gc-root-devshell-start
gc-root-devshell-start:
	@rm -f $(gc_root_name)
	@SYSTEM=$$(nix eval --raw --impure --expr "builtins.currentSystem"); \
		nix build ".#devShells.$$SYSTEM.default" \
		--out-link $(gc_root_name) 2>/dev/null &

# Wait for devShell build to complete and pin as GC root
.PHONY: gc-root-devshell-cleanup
gc-root-devshell-cleanup:
	@while [ ! -e $(gc_root_name) ]; do \
		echo "Waiting for devshell job to finish..."; \
		sleep 1; \
	done
	@ln -sfn $(PWD)/$(gc_root_name) $(gc_root_dir)/$(gc_root_name)
