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
  version = "0.8.0";

  src = fetchgit {
    url = "git://git.proxmox.com/git/ui/pve-yew-mobile-gui.git";
    rev = "ccb273f8187d8c78eda2710777d26a8ccb044495";
    hash = "sha256-YLCu7m49S4IApHEYazyhu3Tvo9q2mMOor1tC1qBSzW8=";
    fetchSubmodules = true;
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  postPatch = ''
    # Strip the upstream `[patch.crates-io]` section from Cargo.toml without
    # eating subsequent sections (e.g. `[lints.clippy]` introduced in 0.7.0).
    # We delete `[patch.crates-io]` plus the lines that follow until (but not
    # including) the next section header line.
    sed -i '/^\[patch\.crates-io\]/,/^\[/{ /^\[patch\.crates-io\]/d; /^\[/!d; }' Cargo.toml

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
