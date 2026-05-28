{
  description = "A nixvim configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-auto-follow.url = "github:xav-ie/nix-auto-follow/feat-consolidation";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixvim.url = "github:nix-community/nixvim";
    systems.url = "github:nix-systems/default";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # transitive dependencies pinned for nix-auto-follow
    flake-utils.url = "github:numtide/flake-utils";

    # vendored
    bgwinch.flake = false;
    bgwinch.url = "github:will/bgwinch.nvim";
    cursortab-nvim.flake = false;
    cursortab-nvim.url = "github:leonardcser/cursortab.nvim";
    minuet-ai-nvim.flake = false;
    minuet-ai-nvim.url = "github:milanglacier/minuet-ai.nvim";
    oil-git-status.flake = false;
    oil-git-status.url = "github:refractalize/oil-git-status.nvim";
    schemastore-nvim.flake = false;
    schemastore-nvim.url = "github:b0o/SchemaStore.nvim";
    tabscope-nvim.flake = false;
    tabscope-nvim.url = "github:backdround/tabscope.nvim";
    vim-guise.flake = false;
    vim-guise.url = "github:lambdalisue/vim-guise";
    vscoq.url = "github:rocq-prover/vscoq";
    # Pin vscoq's nixpkgs: the latest nixpkgs has a broken coq.ocamlPackages
    # (yojson 2.2.2 masquerading as 3.0.0) that breaks vscoq's build. Pin to
    # the last revision where it built successfully.
    vscoq.inputs.nixpkgs.url = "github:NixOS/nixpkgs/f6b44b2401525650256b977063dbcf830f762369";
    vscoq.inputs.nixpkgs-unstable.follows = "vscoq/nixpkgs";
    himalaya-nvim.flake = false;
    himalaya-nvim.url = "github:xav-ie/himalaya-nvim";
    witt-neovim.flake = false;
    witt-neovim.url = "github:typed-rocks/witt-neovim";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [ inputs.treefmt-nix.flakeModule ];

      perSystem =
        {
          lib,
          pkgs,
          system,
          ...
        }:
        let
          nixvimLib = inputs.nixvim.lib.${system};
          nixvim' = inputs.nixvim.legacyPackages.${system};
          nixvimModule = {
            inherit pkgs;
            module = import ./config; # import the module directly
            # You can use `extraSpecialArgs` to pass additional arguments to
            # your module files
            extraSpecialArgs = {
              inherit inputs system; # neovim-nightly-overlay;
            };
          };
          nvim = nixvim'.makeNixvimWithModule nixvimModule;
        in
        {
          devShells.default = pkgs.mkShell {
            packages =
              (with pkgs; [
                nix-output-monitor # nom
                dix # derivation differ
              ])
              ++ [ inputs.nix-auto-follow.packages.${system}.default ];

            shellHook = ''
              printf "\n📝 xnixvim development environment"
              printf "\n🔨 Use \e[1;32mmake \e[2m(build)\e[0m to build the project."
              printf "\n✨ Use \e[1;32mmake format\e[0m to format the files."
              printf "\n🔄 Use \e[1;32mmake update\e[0m to update flake inputs.\n"
            '';
          };

          checks = {
            # Run `nix flake check` to verify that your config is not broken
            default = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;
            # TODO: add `nix run github:fzakaria/nix-auto-follow -- -c`
          };

          # https://flake.parts/options/treefmt-nix.html#options
          treefmt = {
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
              "welcome.tape"
            ];
          };

          packages = {
            # Lets you run `nix run .` to start nixvim
            default = nvim;

            # depends on host-system chromium and fonts :(
            # TODO: use snowfall vhs with mac bundled chromium
            build-demo =
              let
                videoName = "welcome.mp4";
              in
              pkgs.writeShellScriptBin "build-demo" ''
                ${lib.getExe pkgs.vhs} ./welcome.tape -o ${videoName}
                ${lib.getExe pkgs.ffmpeg} -i ${videoName} \
                -vf "unsharp=5:5:0.8:5:5:0.8, eq=saturation=1.2" -vcodec libx264 \
                -crf 28 -an -preset veryslow -y output.mp4
                mv output.mp4 ${videoName}
              '';
          };
        };
    };
}
