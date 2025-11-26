{
  lib,
  stdenv,
  rustPlatform,
  binaryen,
  cargo,
  rustc,
  pkg-config,
  fetchgit,
  mkRegistry,
}:

let
  sources = import ./sources.nix;
  registry = mkRegistry sources;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "proxmox-wasm-builder";
  version = "0.3.0-1";

  src = fetchgit {
    url = "git://git.proxmox.com/git/ui/proxmox-wasm-builder.git";
    rev = "160f45fec3993f238ff2bc54d5bfef4a8877f34c";
    hash = "sha256-LJp2nf1qpP/sJXeBDwSsany6X1BuidvUXA1j1HCMExc=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  postPatch = ''
    rm .cargo/config.toml
    cat ${registry}/cargo-patches.toml >> Cargo.toml
    ln -s ${./Cargo.lock} Cargo.lock

    substituteInPlace ./Makefile \
      --replace-fail 'include /usr/share/dpkg/pkg-info.mk' "" \
      --replace-fail 'include /usr/share/dpkg/architecture.mk' ""
  '';

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = [
    binaryen
    pkg-config
    registry
  ];

  makeFlags = [
    "BUILDIR=$NIX_BUILD_TOP"
    "BUILD_MODE=release"
    "DESTDIR=$(out)"
  ];

  installPhase = ''
    mkdir -p $out/bin
    mv target/release/proxmox-wasm-builder $out/bin/
  '';

  passthru = {
    inherit registry;

    # This package is not in the Proxmox repository
    # updateScript = pve-update-script { };
  };

  meta = with lib; {
    description = "Proxmox rust to WASM build tool";
    homepage = "https://git.proxmox.com/?p=ui/proxmox-wasm-builder.git";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
})
