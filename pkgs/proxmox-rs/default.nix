{
  lib,
  fetchgit,
  pkg-config,
  openssl,
  zstd,
  clang,
  libclang,
  libuuid,
  systemdLibs,
  craneLib,
}:

craneLib.buildPackage rec {
  pname = "proxmox-rs";
  version = "2024-06-13";

  src = fetchgit {
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "b25edb67de09ab22e33ba4db8d445f1e3c8ebab7";
    hash = "sha256-2ND/qP5hDDTov/JwbnVjBH1uAT3EpecerVm24W+1M94=";
  };

  postPatch = ''
    rm .cargo/config
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoVendorDir = craneLib.vendorCargoDeps { cargoLock = ./Cargo.lock; };

  doInstallCargoArtifacts = true;

  nativeBuildInputs = [
    pkg-config
    clang
    zstd
    zstd.dev
  ];
  buildInputs = [
    openssl
    zstd
    clang
    zstd.dev
    libuuid
    systemdLibs
  ];
  LIBCLANG_PATH = "${libclang.lib}/lib";

  cargoTestExtraArgs = "-- --skip=test_get_current_release_codename rrd::tests::load_and_save_rrd_v2 rrd::tests::upgrade_from_rrd_v1";

  passthru.updateScript = [
    ../update.py
    pname
    "--url"
    src.url
  ];

  meta = with lib; {
    description = "";
    homepage = "git://git.proxmox.com/?p=proxmox.git";
    maintainers = with maintainers; [ julienmalka ];
    mainProgram = "proxmox";
  };
}
