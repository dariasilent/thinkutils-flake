## An unofficial nix flake for the thinkutils program

I saw that there is no flake or official package for the thinkutils program and decided to make one on my own.
I am very much a nix beginner so if you see any issues please do inform me about them or send a pull request.

### Installation
Add ```github:dariasilent/thinkutils-nix``` as a flake input, ```thinkutils.nixosModules.default``` as a module,
and install by adding ```programs.thinkutils.enable = true;``` into your nix configuration.  

Optionally you can also add ```programs.thinkutils.sysfsPermissions = true;``` to make the programs permissions persistent.  
(useful if you change your cpu governor options often)

Here is an example how the installation should look like.

### flake.nix:
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

### configuration.nix:
```
programs.thinkutils.enable = true;
programs.thinkutils.sysfsPermissions = true;
```






## Important side note
I added a patch that makes it so the fan speed utility is forced to read the temperatures through hwmon because on some devices ```thermal_zone0``` is a placeholder that never changes value.  
Please note that this patch has no negative side effects on devices where the feature works out of the box.
