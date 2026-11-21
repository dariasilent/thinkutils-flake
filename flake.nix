{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
        pname = "thinkutils";
        version = "0.2.0";

        src = pkgs.fetchFromGitHub {
          owner = "vietanhdev";
          repo = "ThinkUtils";
          rev = "v0.2.0";
          hash = "sha256-NnaTFIAovraZFmv0KTxZG3wYeojZvLy913l4t31LT9Y=";
        };

        cargoRoot = "src-tauri";
        buildAndTestSubdir = finalAttrs.cargoRoot;
        cargoHash = "sha256-Csd8PkZBzdNNzQcjVJI5rU4ht6GwLikfJI61PR6WkP8=";

        nativeBuildInputs = with pkgs; [
          cargo-tauri.hook
          pkg-config
          wrapGAppsHook4
        ];

        buildInputs = with pkgs; [
          webkitgtk_4_1
          gtk3
          libsoup_3
          openssl
          glib-networking
          librsvg
          libayatana-appindicator
        ];

        doCheck = false; # the repo's tests include packaging/CI checks

        # Helper and polkit files from the repo's packaging/ directory
                postPatch = ''
          substituteInPlace src-tauri/src/fan_control.rs \
            --replace-fail '"/usr/lib/thinkutils/thinkutils-fan-control"' \
                           "\"$out/libexec/thinkutils/thinkutils-fan-control\""
        '';

        postInstall = ''
          mkdir -p $out/libexec/thinkutils
          substitute ${finalAttrs.src}/packaging/helper/thinkutils-fan-control \
            $out/libexec/thinkutils/thinkutils-fan-control \
            --replace-fail "#!/bin/bash" "#!${pkgs.bash}/bin/bash"
          chmod 755 $out/libexec/thinkutils/thinkutils-fan-control

          mkdir -p $out/share/polkit-1/rules.d
          substitute ${finalAttrs.src}/packaging/polkit/50-thinkutils.rules \
            $out/share/polkit-1/rules.d/50-thinkutils.rules \
            --replace-fail "/usr/lib/thinkutils/thinkutils-fan-control" \
                           "$out/libexec/thinkutils/thinkutils-fan-control"
        '';
        dontWrapGApps = true;

        postFixup = ''
          wrapProgram $out/bin/thinkutils \
            "''${gappsWrapperArgs[@]}" \
            --prefix PATH : /run/wrappers/bin \
            --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [ pkgs.libayatana-appindicator ]}
        '';
      });
    };
}
