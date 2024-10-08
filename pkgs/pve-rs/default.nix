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
  perl536,
  perlmod,
}:

perl536.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-rs";
    version = "0.8.9";

    src = fetchgit {
      url = "git://git.proxmox.com/git/proxmox-perl-rs.git";
      rev = "cd0e7b8cd2f3e4ece77e0331fb881d87b91a1c18";
      hash = "sha256-Jxcw3E6J30SFdLj/zpAcT42hGYngh3HKlyNZ4orCnQM=";
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
      perl536
    ];

    buildInputs = [
      libuuid
      pkg-config
      openssl
    ];

    makeFlags = [
      "BUILDIR=$NIX_BUILD_TOP"
      "BUILD_MODE=release"
      "DESTDIR=$(out)"
      "GITVERSION:=${src.rev}"
      "PERL_INSTALLVENDORARCH=/${perl536.libPrefix}/${perl536.version}"
      "PERL_INSTALLVENDORLIB=/${perl536.libPrefix}/${perl536.version}"
    ];

    postInstall = ''
      (
        cd common/pkg
        PERL_INSTALLVENDORLIB=$out/${perl536.libPrefix}/${perl536.version} make install
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
