{
  lib,
  fetchgit,
  craneLib,
  pkg-config,
  clang,
  zstd,
  apt,
  sg3_utils,
  libclang,
  proxmox-backup,
  openssl,
  libxcrypt,
  acl,
  linux-pam,
  libuuid,
}:

let

  isProxmoxRS = p: lib.hasPrefix "git+https://github.com/proxmox/proxmox-rs.git" p.source;
in
craneLib.buildPackage rec {
  pname = "proxmox-backup-qemu";
  version = "1.3.2";

  src = fetchgit {
    url = "git://git.proxmox.com/git/${pname}.git";
    rev = "afc3670334a5c911a14725bc9df2a96ac8066781";
    hash = "sha256-9d73I+JL47MHLhvEnLSbO4xcYVu187oN9YKkTzwUlSk=";
    fetchSubmodules = false;
  };

  postPatch = ''
    ls
    rm -rf .cargo
    cp ${./Cargo.lock} Cargo.lock
    cp ${./Cargo.toml} Cargo.toml
    cp -r ${proxmox-backup.src} proxmox-backup
    chmod -R 744 proxmox-backup
    cp ${../proxmox-backup/Cargo.toml} proxmox-backup/Cargo.toml
    cp ${../proxmox-backup/Cargo.lock} proxmox-backup/Cargo.lock
    ls
  '';

  REPOID = "lol";

  cargoVendorDir = craneLib.vendorCargoDeps {
    cargoLock = ./Cargo.lock;
    overrideVendorGitCheckout =
      ps: drv:
      if (lib.any isProxmoxRS ps) then
        (drv.overrideAttrs (_old: {
          postPatch = ''
            rm .cargo/config 
          '';
        }))
      else
        drv;
  };

  cargoArtifacts = craneLib.buildDepsOnly {
    inherit
      src
      cargoVendorDir
      postPatch
      REPOID
      nativeBuildInputs
      LIBCLANG_PATH
      ;
    dummySrc = src;
  };

  nativeBuildInputs = [
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
    libuuid
  ];

  buildInputs = [
    zstd
    clang
    zstd.dev
  ];

  postInstall = ''
    cp proxmox-backup-qemu.h $out/lib
    cp target/release/libproxmox_backup_qemu.so $out/lib/libproxmox_backup_qemu.so.0
  '';

  LIBCLANG_PATH = "${libclang.lib}/lib";

  cargoTestExtraArgs = "-- --skip=test_get_current_release_codename rrd::tests::load_and_save_rrd_v2 rrd::tests::upgrade_from_rrd_v1";
}
