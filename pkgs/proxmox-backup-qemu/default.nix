{
  fetchgit,
  pkg-config,
  clang,
  zstd,
  apt,
  sg3_utils,
  libclang,
  openssl,
  libxcrypt,
  acl,
  linux-pam,
  libuuid,
  rustPlatform,
  git,
  mkRegistry,
}:
let
  sources = import ./sources.nix;
  registry = mkRegistry sources;
in
rustPlatform.buildRustPackage rec {
  pname = "proxmox-backup-qemu";
  version = "1.5.1";

  src = fetchgit {
    url = "git://git.proxmox.com/git/${pname}.git";
    rev = "c3cbcae289d04b4454a70fc59dc58a19d5edb681";
    hash = "sha256-qynY7bt+lOzpg4YxeUnRk7/xoSbtk+tWGbuNMmAdzHY=";
    fetchSubmodules = true;
  };

  patches = [ ./backup-toml.patch ];
  patchFlags = [
    "-p1"
    "-d"
    "submodules/proxmox-backup/"
  ];

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    rm -rf .cargo
    cat ${registry}/cargo-patches.toml >> Cargo.toml
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    acl
    pkg-config
    clang
    zstd
    zstd.dev
    apt
    sg3_utils
    openssl
    sg3_utils
    libxcrypt
    acl
    linux-pam
    git
  ];

  buildInputs = [
    acl
    libxcrypt
    libuuid
    zstd
    clang
    zstd.dev
    registry
    git
    openssl
  ];

  passthru.registry = registry;

  postInstall = ''
    cp proxmox-backup-qemu.h $out/lib
    cp target/*/release/libproxmox_backup_qemu.so $out/lib/libproxmox_backup_qemu.so.0
  '';

  LIBCLANG_PATH = "${libclang.lib}/lib";

  cargoTestExtraArgs = "-- --skip=test_get_current_release_codename rrd::tests::load_and_save_rrd_v2 rrd::tests::upgrade_from_rrd_v1";
}
