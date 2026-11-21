# thinkutils-flake
A nix flake for the thinkutils program

I saw that there is no flake or official package for the thinkutils program and decided to make one on my own.

add `github:dariasilent/thinkutils-flake` as a flake input and install by adding `programs.thinkutils.enable = true;` into your nix configuration.

(Optionally) you can also add `programs.thinkutils.sysfsPermissions = true;` to make the programs permissions persistent.

here is an example how the installation should look like:


