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
  perl,
  perlmod,
  callPackage,
}:

perl.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-rs";
    version = "0.8.3";

    src = fetchgit {
      url = "https://git.proxmox.com/git/proxmox-perl-rs.git";
      rev = "3df4aecac06907109099b6e7960c339f942668df";
      hash = "sha256-OUbU15sVWaf6eh1IU2BgOuUK9/vPa9yvLg37gWp4U8k=";
    };

    cargoDeps = rustPlatform.importCargoLock {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "perlmod-0.13.2" = "sha256-ByP1jubfoRfc/DmdGwjT+uxU+jz9LE4KSN/jkRxeBxc=";
        "proxmox-api-macro-1.0.4" = "sha256-EKWOGilPdGe+yB7yXrTlhNpgTTq1lU6p6nwPL2XcD7U=";
        "proxmox-resource-scheduling-0.3.0" = "sha256-WO5cVkurt7I0V0/7P19dllRaUbd2iFHGClfOnWbxraA=";
      };
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
      rm .cargo/config Cargo.toml
      ln -s ${./Cargo.toml} Cargo.toml
      ln -s ${./Cargo.lock} Cargo.lock
    '';

    nativeBuildInputs = [
      rustPlatform.cargoSetupHook
      cargo
      rustc
      perl
    ];

    buildInputs = [
      libuuid
      pkg-config
      openssl
    ];

    makeFlags = [
      "BUILDIR=/build"
      "BUILD_MODE=release"
      "DESTDIR=$(out)"
      "GITVERSION:=${src.rev}"
      "PERL_INSTALLVENDORARCH=/${perl.libPrefix}/${perl.version}"
      "PERL_INSTALLVENDORLIB=/${perl.libPrefix}/${perl.version}"
    ];

    postInstall = ''
      (
        cd common/pkg
        PERL_INSTALLVENDORLIB=$out/${perl.libPrefix}/${perl.version} make install
      )    
    '';

    passthru.updateScript = callPackage ../update.nix { inherit src pname; };

    meta = with lib; {
      description = "Proxmox rust interface for perl";
      homepage = "https://git.proxmox.com/git/proxmox-perl-rs.git";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
