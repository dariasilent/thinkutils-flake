{
  description = "ThinkUtils (ThinkPad fan, battery and CPU control) for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in {
      packages = forAllSystems (pkgs: rec {
        thinkutils = pkgs.callPackage ./package.nix { };
        default = thinkutils;
      });

      overlays.default = final: _prev: {
        thinkutils = final.callPackage ./package.nix { };
      };

      nixosModules.default = import ./module.nix self;
    };
}
