{
  mkRegistry,
  rustPlatform,
  fetchgit,
  git,
  pkg-config,
  acl,
  apt,
  clang,
  libclang,
  libuuid,
  libxcrypt,
  linux-pam,
  openssl,
  sg3_utils,
  systemd,
  zstd,
  pve-update-script,
}:

let
  sources = import ./sources.nix;
  registry = mkRegistry sources;
in

rustPlatform.buildRustPackage rec {
  pname = "proxmox-backup-qemu";
  version = "2.0.2";

  src = fetchgit {
    url = "git://git.proxmox.com/git/${pname}.git";
    rev = "594183eab9fa275f45dfff5dd15b16f150abd503";
    hash = "sha256-YjP4TI/MoobK1RAdaDS3MO91DXsS55OFv9dpdXSkZmU=";
    fetchSubmodules = true;
  };

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    rm -rf .cargo
    cat ${registry}/cargo-patches.toml >> Cargo.toml
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    git
    pkg-config
  ];

  buildInputs = [
    acl
    apt
    clang
    libuuid
    libxcrypt
    linux-pam
    openssl
    registry
    sg3_utils
    systemd
    zstd.dev
  ];

  passthru = {
    inherit registry;

    updateScript = pve-update-script {
      extraArgs = [
        "--deb-name"
        "libproxmox-backup-qemu0"
        "--use-git-log"
      ];
    };
  };

  postInstall = ''
    cp proxmox-backup-qemu.h $out/lib
    cp target/*/release/libproxmox_backup_qemu.so $out/lib/libproxmox_backup_qemu.so.0
  '';

  LIBCLANG_PATH = "${libclang.lib}/lib";

  cargoTestExtraArgs = "-- --skip=test_get_current_release_codename rrd::tests::load_and_save_rrd_v2 rrd::tests::upgrade_from_rrd_v1";
}
