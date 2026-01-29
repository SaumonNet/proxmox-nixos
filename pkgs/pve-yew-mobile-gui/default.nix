{
  lib,
  stdenv,
  rustPlatform,
  binaryen,
  cargo,
  esbuild,
  grass-sass,
  gzip,
  rustc,
  libuuid,
  lld,
  pkg-config,
  openssl,
  fetchgit,
  proxmox-wasm-builder,
  mkRegistry,
  pve-update-script,
}:

let
  sources = import ./sources.nix;
  registry = mkRegistry sources;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "pve-yew-mobile-gui";
  version = "0.6.4";

  src = fetchgit {
    url = "git://git.proxmox.com/git/ui/pve-yew-mobile-gui.git";
    rev = "c0c8d4863387c28fa8db2c31ce65779bbaf39318";
    hash = "sha256-EE73KfzXgcI9n5bkC1tAo2EVWGpIk/FzXJjkEDDMZ6E=";
    fetchSubmodules = true;
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  postPatch = ''
    # Remove the `[patch.crates-io]` section from original Cargo.toml
    sed -i '/\[patch.crates-io\]/,/^\[/d' Cargo.toml

    rm .cargo/config.toml
    cat ${registry}/cargo-patches.toml >> Cargo.toml
    ln -s ${./Cargo.lock} Cargo.lock

    substituteInPlace ./Makefile \
      --replace-fail 'include /usr/share/dpkg/default.mk' "" \
      --replace-fail 'rust-grass' 'grass'
  '';

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    lld
    rustc
  ];

  buildInputs = [
    binaryen
    esbuild
    grass-sass
    gzip
    libuuid
    pkg-config
    proxmox-wasm-builder
    openssl
    registry
  ];

  makeFlags = [
    "BUILDIR=$NIX_BUILD_TOP"
    "BUILD_MODE=release"
    "DESTDIR=$(out)"
    "GITVERSION:=${finalAttrs.src.rev}"
    "PREFIX="
  ];

  passthru = {
    inherit registry;

    updateScript = pve-update-script { };
  };

  meta = with lib; {
    description = "Mobile web UI for Proxmox VE based on Yew";
    homepage = "https://git.proxmox.com/?p=ui/pve-yew-mobile-gui.git";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
})
