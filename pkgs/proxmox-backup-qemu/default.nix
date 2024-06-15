{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  rustPlatform,
  rustc,
}:

stdenv.mkDerivation rec {
  pname = "proxmox-backup-qemu";
  version = "unstable-2023-11-03";

  src = fetchFromGitHub {
    owner = "proxmox";
    repo = "proxmox-backup-qemu";
    rev = "8984a42b404fdb1761b105a4d82ffbd55dbf30e5";
    hash = "sha256-awUshqH9eSGY8xxKP9fq5W98TQQ20ckW0J4JdSrSIQs=";
    fetchSubmodules = true;
  };

  cargoDeps = rustPlatform.importCargoLock { lockFile = ./Cargo.lock; };

  postPatch = ''
    rm {submodules/proxmox-backup/,}.cargo/config
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    cargo
    rustPlatform.cargoSetupHook
    rustc
  ];

  passthru.updateScript = [
    ../update.sh
    pname
    src.url
  ];

  meta = with lib; {
    description = "Library to integrate Proxmox Backup into QEMU";
    homepage = "https://github.com/proxmox/proxmox-backup-qemu";
    license = [ ]; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    mainProgram = "proxmox-backup-qemu";
    platforms = platforms.all;
  };
}
