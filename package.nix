{ lib, rustPlatform, fetchFromGitHub, cargo-tauri, pkg-config, wrapGAppsHook4, bash
, webkitgtk_4_1, gtk3, libsoup_3, openssl, glib-networking, librsvg, libayatana-appindicator
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "thinkutils";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "vietanhdev";
    repo = "ThinkUtils";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NnaTFIAovraZFmv0KTxZG3wYeojZvLy913l4t31LT9Y=";
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoHash = "sha256-Csd8PkZBzdNNzQcjVJI5rU4ht6GwLikfJI61PR6WkP8=";

  nativeBuildInputs = [ cargo-tauri.hook pkg-config wrapGAppsHook4 ];
  buildInputs = [
    webkitgtk_4_1 gtk3 libsoup_3 openssl glib-networking librsvg libayatana-appindicator
  ];

  doCheck = false; # the packaging test compares against the unpatched helper path
  dontWrapGApps = true;

  postPatch = ''
    substituteInPlace src-tauri/src/fan_control.rs \
      --replace-fail '"/usr/lib/thinkutils/thinkutils-fan-control"' \
                     "\"$out/libexec/thinkutils/thinkutils-fan-control\""
  '';

  postInstall = ''
    mkdir -p $out/libexec/thinkutils
    substitute ${finalAttrs.src}/packaging/helper/thinkutils-fan-control \
      $out/libexec/thinkutils/thinkutils-fan-control \
      --replace-fail "#!/bin/bash" "#!${bash}/bin/bash"
    chmod 755 $out/libexec/thinkutils/thinkutils-fan-control

    mkdir -p $out/share/polkit-1/rules.d
    substitute ${finalAttrs.src}/packaging/polkit/50-thinkutils.rules \
      $out/share/polkit-1/rules.d/50-thinkutils.rules \
      --replace-fail "/usr/lib/thinkutils/thinkutils-fan-control" \
                     "$out/libexec/thinkutils/thinkutils-fan-control"
  '';

  postFixup = ''
    wrapProgram $out/bin/thinkutils \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : /run/wrappers/bin \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libayatana-appindicator ]}
  '';

  meta = {
    description = "ThinkPad fan control, battery care and system monitoring";
    homepage = "https://github.com/vietanhdev/ThinkUtils";
    license = lib.licenses.lgpl3Plus;
    mainProgram = "thinkutils";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
})
