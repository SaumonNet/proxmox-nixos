{ lib
, rustPlatform
, fetchgit
, pkg-config
, openssl
, zstd
, clang
, libclang
, libuuid
, systemdLibs
, diffutils
}:

rustPlatform.buildRustPackage {
  pname = "proxmox-rs";
  version = "2024-06-13";

  src = fetchgit {
    url = "https://git.proxmox.com/git/proxmox.git";
    rev = "b25edb67de09ab22e33ba4db8d445f1e3c8ebab7";
    hash = "sha256-2ND/qP5hDDTov/JwbnVjBH1uAT3EpecerVm24W+1M94=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
    rm .cargo/config

    sed -i proxmox-rrd/tests/file_format_test.rs -e "s|/usr/bin/cmp|${diffutils}/bin/cmp|"
  '';

  nativeBuildInputs = [ pkg-config clang zstd zstd.dev ];
  buildInputs = [ openssl zstd clang zstd.dev libuuid systemdLibs ];
  LIBCLANG_PATH = "${libclang.lib}/lib";

  installPhase = ''
    mkdir -p $out/share
    # cp -r /build/cargo-vendor-dir $out/share
    cp -r /build/target $out/share
  '';

  checkFlags = [ "--skip=test_get_current_release_codename" ];


  meta = with lib; {
    description = "";
    homepage = "https://git.proxmox.com/git/proxmox.git";
    maintainers = with maintainers; [ camillemndn julienmalka ];
    mainProgram = "proxmox";
  };
}
