{
  lib,
  stdenv,
  fetchgit,
  perl5,
  pve-access-control,
  pve-apiclient,
  pve-rs,
  bash,
  check,
  corosync,
  fuse,
  glib,
  gzip,
  libfaketime,
  libqb,
  libxcrypt,
  makeWrapper,
  openssh,
  openssl,
  pkg-config,
  rrdtool,
  sqlite,
  systemd,
  uuid,
  pve-update-script,
}:

let
  perlDeps = with perl5.pkgs; [
    DigestHMAC
    uuid
    (rrdtool.override { perl = perl5; })
    pve-access-control
    pve-apiclient
    pve-rs
  ];

  perlEnv = perl5.withPackages (_: perlDeps);
in

perl5.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-cluster";
    version = "9.1.6";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "7091d92e594952dba65c1e57568b3d7cc244e960";
      hash = "sha256-NCG8O8mvF3WhZZISFT7BzHCQxuoV9FKar+6IGw3L7uE=";
    };

    sourceRoot = "${src.name}/src";

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
      "PERL_VENDORARCH=${perl5.libPrefix}/${perl5.version}"
      "PVEDIR=$(out)/${perl5.libPrefix}/${perl5.version}/PVE"
    ];

    postInstall = ''
      cp ${pve-access-control}/.bin/* $out/bin
    '';

    postFixup = ''
      find $out/lib -type f | xargs sed -i -re "s|(/usr)?/s?bin/||"

      for bin in $out/bin/*; do
        wrapProgram $bin \
          --prefix PATH : ${
            lib.makeBinPath [
              openssh
              openssl
              bash
              systemd
              sqlite
              gzip
              corosync
              libfaketime
            ]
          } \
          --prefix PERL5LIB : $out/${perl5.libPrefix}/${perl5.version}
      done      
    '';

    passthru.updateScript = pve-update-script { };

    meta = with lib; {
      description = "Proxmox VE Cluster FS and Tools";
      homepage = "https://git.proxmox.com/?p=pve-cluster.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
