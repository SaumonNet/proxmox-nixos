{ lib
, stdenv
, fetchFromGitHub
, callPackage
, perl
, pve-access-control ? callPackage ./access-control.nix { }
, pve-apiclient ? callPackage ./apiclient.nix { }
, pve-rs ? callPackage ./rs { }
, bash
, check
, corosync
, fuse
, glib
, libfaketime
, libqb
, libxcrypt
, makeWrapper
, openssh
, openssl
, pkg-config
, rrdtool
, sqlite
, systemd
}:

let
  perlDeps = with perl.pkgs; with callPackage ../perl-packages.nix { }; [
    DigestHMAC
    UUID
    rrdtool
    pve-access-control
    pve-apiclient
    pve-rs
  ];

  perlEnv = perl.withPackages (_: perlDeps);
in

perl.pkgs.toPerlModule (stdenv.mkDerivation {
  pname = "pve-cluster";
  version = "8.0.2";

  src = fetchFromGitHub {
    owner = "proxmox";
    repo = "pve-cluster";
    rev = "a56696c2a0585e3f3d503204da3bf2fd0995ddaa";
    hash = "sha256-ojnO4Ogu88PF/gff0QGf5uf/O34RJW30RIQPPFaODWQ=";
  };

  sourceRoot = "source/src";

  postPatch = ''
    find . -type f -name Makefile | xargs sed -i "s|/usr||g"
    sed -i PVE/Makefile \
      -e "/install -D pvecm.1/,+3d" \
      -e "s/pvecm.1 pvecm.bash-completion pvecm.zsh-completion datacenter.cfg.5//"
    sed -i pmxcfs/Makefile \
      -e "s/ pmxcfs.8//" \
      -e "/CFLAGS += -std/,+3d" \
      -e "s/-MMD.*//" \
      -e "s/-Wl,-z,relro //" \
      -e "/pmxcfs.8/d"
  '';

  buildInputs = [
    check
    corosync
    fuse
    glib
    libqb
    libxcrypt
    makeWrapper
    pkg-config
    rrdtool
    sqlite
    perlEnv
  ];

  propagatedBuildInputs = perlDeps;

  makeFlags = [
    "DESTDIR=$(out)"
    "PERL_VENDORARCH=${perl.libPrefix}/${perl.version}"
    "PVEDIR=$(out)/${perl.libPrefix}/${perl.version}/PVE"
  ];

  postInstall = ''
    cp ${pve-access-control}/.bin/* $out/bin
  '';

  postFixup = ''
    find $out/lib -type f | xargs sed -i -re "s|[/usr]?/s?bin/||"

    for bin in $out/bin/*; do
      wrapProgram $bin \
        --prefix PATH : ${lib.makeBinPath [ openssh openssl bash systemd corosync libfaketime ]} \
        --prefix PERL5LIB : $out/${perl.libPrefix}/${perl.version}
    done      
  '';

  meta = with lib; {
    description = "Cluster FS and Tools";
    homepage = "https://github.com/proxmox/pve-cluster";
    license = with licenses; [ ];
    maintainers = with maintainers; [ camillemndn julienmalka ];
    platforms = platforms.linux;
  };
})
