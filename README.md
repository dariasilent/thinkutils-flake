# thinkutils-flake
A nix flake for the thinkutils program

I saw that there is no flake or official package for the thinkutils program and decided to make one on my own.

add `github:dariasilent/thinkutils-flake` as a flake input, add `{ _module.args.thinkutils = thinkutils.packages.x86_64-linux.default; }` into modules and install thinkutils by adding `thinkutils` into inputs in configuration.nix and `environment.systemPackages = [ thinkutils ]`

here is an example how the installation should look like:


