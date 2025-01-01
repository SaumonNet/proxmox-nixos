{
  lib,
  stdenv,
  fetchgit,
  perl538,
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
}:

let
  perlDeps = with perl538.pkgs; [
    DigestHMAC
    uuid
    (rrdtool.override { perl = perl538; })
    pve-access-control
    pve-apiclient
    pve-rs
  ];

  perlEnv = perl538.withPackages (_: perlDeps);
in

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-cluster";
    version = "8.0.10";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "3749d370ac2e1e73d2558f8dbe5d7f001651157c";
      hash = "sha256-/DQ59CGlK8UDQFpnXnE8rrJ0sgtG4G5J6BpsBV2gHPg=";
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
      "PERL_VENDORARCH=${perl538.libPrefix}/${perl538.version}"
      "PVEDIR=$(out)/${perl538.libPrefix}/${perl538.version}/PVE"
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
          --prefix PERL5LIB : $out/${perl538.libPrefix}/${perl538.version}
      done      
    '';

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
    ];

    meta = with lib; {
      description = "Proxmox VE Cluster FS and Tools";
      homepage = "git://git.proxmox.com/?p=pve-cluster.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
