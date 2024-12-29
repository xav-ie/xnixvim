{
  description = "A nixvim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixvim.url = "github:nix-community/nixvim";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # vendored
    coq-lsp.url = "github:tomtomjhj/coq-lsp.nvim";
    coq-lsp.flake = false;

    coqtail.url = "github:whonore/Coqtail";
    coqtail.flake = false;

    oatmeal.url = "github:dustinblackman/oatmeal.nvim";
    oatmeal.flake = false;

    octo-nvim.url = "github:pwntester/octo.nvim";
    octo-nvim.flake = false;

    oil-git-status.url = "github:refractalize/oil-git-status.nvim";
    oil-git-status.flake = false;

    org-roam-nvim.url = "github:chipsenkbeil/org-roam.nvim";
    org-roam-nvim.flake = false;

    orgmode.url = "github:nvim-orgmode/orgmode";
    orgmode.flake = false;

    schemastore-nvim.url = "github:b0o/SchemaStore.nvim";
    schemastore-nvim.flake = false;

    tabscope-nvim.url = "github:backdround/tabscope.nvim";
    tabscope-nvim.flake = false;

    vim-guise.url = "github:lambdalisue/vim-guise";
    vim-guise.flake = false;

    witt-neovim.url = "github:typed-rocks/witt-neovim";
    witt-neovim.flake = false;
  };

  outputs =
    {
      nixvim,
      flake-parts,
      # neovim-nightly-overlay,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # TODO: copy this excellent nixvim config:
      # https://github.com/asungy/nixim/blob/979643e6a13d1803915b379a0e974b86cbcd77ea/flake.nix
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        { pkgs, system, ... }:
        let
          nixvimLib = nixvim.lib.${system};
          nixvim' = nixvim.legacyPackages.${system};
          nixvimModule = {
            inherit pkgs;
            module = import ./config; # import the module directly
            # You can use `extraSpecialArgs` to pass additional arguments to your module files
            # idk how to use this
            extraSpecialArgs = {
              inherit inputs;
              # inherit neovim-nightly-overlay;
              inherit system;
            };
          };
          nvim = nixvim'.makeNixvimWithModule nixvimModule;
        in
        {
          checks = {
            # Run `nix flake check .` to verify that your config is not broken
            default = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;
            # TODO: add `nix run github:fzakaria/nix-auto-follow -- -c`
          };

          # https://flake.parts/options/treefmt-nix.html#options
          treefmt = {
            projectRootFile = "./flake.nix";
            programs = {
              deadnix.enable = true;
              nixfmt.enable = true;
              prettier.enable = true;
              statix.enable = true;
              stylua.enable = true;
            };
            settings.global.excludes = [
              # I could not find formatters for these:
              "Makefile"
              ".git-blame-ignore-revs"
            ];
          };

          packages = {
            # Lets you run `nix run .` to start nixvim
            default = nvim;
          };
        };
    };
}
