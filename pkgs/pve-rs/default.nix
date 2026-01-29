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
  perl540,
  perlmod,
  apt,
  mkRegistry,
  pve-update-script,
}:
let
  sources = import ./sources.nix;
  registry = mkRegistry sources;
in

perl540.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-rs";
    version = "0.11.1";

    src = fetchgit {
      url = "git://git.proxmox.com/git/proxmox-perl-rs.git";
      rev = "9f59fe9e71895f3f2348af830fdd76656e139fa4";
      hash = "sha256-sgWwO44hqH4j56y71yzmOSBQIZMkicsSvmWkLalg2a0=";
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
      perl540
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
      "PERL_INSTALLVENDORARCH=/${perl540.libPrefix}/${perl540.version}"
      "PERL_INSTALLVENDORLIB=/${perl540.libPrefix}/${perl540.version}"
    ];

    postInstall = ''
      (
        cd common/pkg
        PERL_INSTALLVENDORLIB=$out/${perl540.libPrefix}/${perl540.version} make install
      )    
    '';

    passthru = {
      inherit registry;

      updateScript = pve-update-script {
        extraArgs = [
          "--deb-name"
          "libpve-rs-perl"
          "--use-git-log"
        ];
      };
    };

    meta = with lib; {
      description = "Proxmox Rust interface for Perl";
      homepage = "https://git.proxmox.com/?p=proxmox-perl-rs.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
