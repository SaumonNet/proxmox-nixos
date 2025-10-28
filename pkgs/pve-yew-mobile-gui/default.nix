{
  lib,
  stdenv,
  rustPlatform,
  cargo,
  rustc,
  libuuid,
  pkg-config,
  openssl,
  fetchgit,
  perl538,
  perlmod,
  apt,
  mkRegistry,
  pve-update-script,
}:

let
  sources = import ./sources.nix;
  registry = mkRegistry sources;
in

stdenv.mkDerivation rec {
  pname = "pve-yew-mobile-gui";
  version = "0.6.2";

  src = fetchgit {
    url = "git://git.proxmox.com/git/ui/pve-yew-mobile-gui.git";
    rev = "4e22axx15e892f75c8c96998feaf1e535b7167b8";
    hash = "sha256-AzH1rZFqEH8sovZZfJykvsEmCedEZWigQFHWHl6/PdE=";
    fetchSubmodules = false;
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  postPatch = ''
    rm .cargo/config.toml
    cat ${registry}/cargo-patches.toml >> Cargo.toml
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc
    perl538
    apt
  ];

  buildInputs = [
    libuuid
    pkg-config
    openssl
    registry
    apt
  ];

  makeFlags = [
    "BUILDIR=$NIX_BUILD_TOP"
    "BUILD_MODE=release"
    "DESTDIR=$(out)"
    "GITVERSION:=${src.rev}"
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
}
