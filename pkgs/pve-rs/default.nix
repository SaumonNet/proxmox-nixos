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
}:
let
  sources = import ./sources.nix;
  registry = mkRegistry sources;
in

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-rs";
    version = "0.9.4";

    src = fetchgit {
      url = "git://git.proxmox.com/git/proxmox-perl-rs.git";
      rev = "22a6b226309923ddf6ca1982e813f5a273e0d427";
      hash = "sha256-YxioQTLVYMSvkZx4pYTjnFto9PhFMODS5ZwLa1Wa/JA=";
    };

    cargoDeps = rustPlatform.importCargoLock {
      lockFile = ./Cargo.lock;
      allowBuiltinFetchGit = true;
    };

    postPatch = ''
      for i in {common/pkg/,pve-rs/}Makefile; do
        sed -i "$i" \
          -e '/GITVERSION/d' \
          -e '/dpkg-architecture/d' \
          -e '/pkg-info/d' \
          -e '/MConfig/d' \
          -e 's,/usr/lib/perlmod/genpackage.pl,${perlmod}/lib/perlmod/genpackage.pl,'
      done
      cd pve-rs
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
      "PERL_INSTALLVENDORARCH=/${perl538.libPrefix}/${perl538.version}"
      "PERL_INSTALLVENDORLIB=/${perl538.libPrefix}/${perl538.version}"
    ];

    postInstall = ''
      (
        cd common/pkg
        PERL_INSTALLVENDORLIB=$out/${perl538.libPrefix}/${perl538.version} make install
      )    
    '';

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
      "--prefix"
      "pve: bump version to"
      "--root"
      pname
    ];

    passthru.registry = registry;

    meta = with lib; {
      description = "Proxmox Rust interface for Perl";
      homepage = "git://git.proxmox.com/?p=proxmox-perl-rs.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
