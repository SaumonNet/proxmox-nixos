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

    passthru.updateScript = [
      ../update.sh
      pname
      src.url
    ];

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
