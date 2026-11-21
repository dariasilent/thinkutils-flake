# thinkutils-nix
## A nix flake for the thinkutils program

I saw that there is no flake or official package for the thinkutils program and decided to make one on my own.

Add `github:dariasilent/thinkutils-nix` as a flake input, add `thinkutils.nixosModules.default` as a module,
and install by adding `programs.thinkutils.enable = true;` into your nix configuration.

(Optionally) you can also add `programs.thinkutils.sysfsPermissions = true;` to make the programs permissions persistent.

Here is an example how the installation should look like.

flake.nix:
```
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    thinkutils = {
      url = "github:dariasilent/thinkutils-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, thinkutils, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        thinkutils.nixosModules.default
      ];
    };
  };
}
```

configuration.nix:
```
programs.thinkutils.enable = true;
programs.thinkutils.sysfsPermissions = true;
```






## side note
i added a patch that makes it so the fan speed utility is forced to read the temperatures through hwmon because my device's first thermal_zone is a placeholder that never changes value.

this has no negative side effects on devices where the feature works without the patch.
