{
  lib,
  stdenv,
  rustPlatform,
  cargo,
  rustc,
  clang,
  libclang,
  libuuid,
  nettle,
  pkg-config,
  openssl,
  systemdLibs,
  fetchgit,
  perl5,
  perlmod,
  apt,
  mkRegistry,
  pve-update-script,
}:
let
  sources = import ./sources.nix;
  registry = mkRegistry sources;
in

perl5.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-rs";
    version = "0.15.3";

    src = fetchgit {
      url = "git://git.proxmox.com/git/proxmox-perl-rs.git";
      rev = "c6b798f72a7e9f1063d75b144835d63781006ef4";
      hash = "sha256-wvCD56HkdpvjJqQ3UlnggUF30yMfhPPM3AALC3ojrAg=";
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
      clang
      perl5
      apt
    ];

    buildInputs = [
      libuuid
      nettle
      pkg-config
      openssl
      systemdLibs
      registry
      apt
    ];

    LIBCLANG_PATH = "${libclang.lib}/lib";

    makeFlags = [
      "BUILDIR=$NIX_BUILD_TOP"
      "BUILD_MODE=release"
      "DESTDIR=$(out)"
      "GITVERSION:=${src.rev}"
      "PERL_INSTALLVENDORARCH=/${perl5.libPrefix}/${perl5.version}"
      "PERL_INSTALLVENDORLIB=/${perl5.libPrefix}/${perl5.version}"
    ];

    postInstall = ''
      (
        cd common/pkg
        PERL_INSTALLVENDORLIB=$out/${perl5.libPrefix}/${perl5.version} make install
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
