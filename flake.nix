{
  description = "A nixvim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = { nixvim, flake-parts, ... }@inputs:
    let config = import ./config; # import the module directly
    in flake-parts.lib.mkFlake { inherit inputs; } {
      # TODO: copy this excellent nixvim config:
      # https://github.com/asungy/nixim/blob/979643e6a13d1803915b379a0e974b86cbcd77ea/flake.nix
      systems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { pkgs, system, ... }:
        let
          nixvimLib = nixvim.lib.${system};
          nixvim' = nixvim.legacyPackages.${system};
          nvim = nixvim'.makeNixvimWithModule {
            inherit pkgs;
            module = config;
            # You can use `extraSpecialArgs` to pass additional arguments to your module files
            # idk how to use this
            extraSpecialArgs = {
              # inherit (inputs) foo;
            };
          };
        in {
          checks = {
            # Run `nix flake check .` to verify that your config is not broken
            default = nixvimLib.check.mkTestDerivationFromNvim {
              inherit nvim;
              name = "A nixvim configuration";
            };
          };

          packages = {
            # Lets you run `nix run .` to start nixvim
            default = nvim;
          };
        };
    };
}
