{
  description = "A nixvim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixvim.url = "github:nix-community/nixvim";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    systems.url = "github:nix-systems/default";
    vscoq.url = "github:rocq-prover/vscoq";
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # vendored
    coq-lsp.flake = false;
    coq-lsp.url = "github:tomtomjhj/coq-lsp.nvim";
    coqtail.flake = false;
    coqtail.url = "github:whonore/Coqtail";
    minuet-ai-nvim.flake = false;
    minuet-ai-nvim.url = "github:milanglacier/minuet-ai.nvim";
    oatmeal.flake = false;
    oatmeal.url = "github:dustinblackman/oatmeal.nvim";
    octo-nvim.flake = false;
    octo-nvim.url = "github:pwntester/octo.nvim";
    oil-git-status.flake = false;
    oil-git-status.url = "github:refractalize/oil-git-status.nvim";
    org-roam-nvim.flake = false;
    org-roam-nvim.url = "github:chipsenkbeil/org-roam.nvim";
    orgmode.flake = false;
    orgmode.url = "github:nvim-orgmode/orgmode";
    schemastore-nvim.flake = false;
    schemastore-nvim.url = "github:b0o/SchemaStore.nvim";
    tabscope-nvim.flake = false;
    tabscope-nvim.url = "github:backdround/tabscope.nvim";
    vim-guise.flake = false;
    vim-guise.url = "github:lambdalisue/vim-guise";
    witt-neovim.flake = false;
    witt-neovim.url = "github:typed-rocks/witt-neovim";
    cmp-luasnip-choice.url = "github:L3MON4D3/cmp-luasnip-choice";
    cmp-luasnip-choice.flake = false;
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
