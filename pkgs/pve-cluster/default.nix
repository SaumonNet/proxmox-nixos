{
  lib,
  stdenv,
  fetchgit,
  perl536,
  pve-access-control,
  pve-apiclient,
  pve-rs,
  bash,
  check,
  corosync,
  fuse,
  glib,
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
  perlDeps = with perl536.pkgs; [
    DigestHMAC
    uuid
    rrdtool
    pve-access-control
    pve-apiclient
    pve-rs
  ];

  perlEnv = perl536.withPackages (_: perlDeps);
in

perl536.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-cluster";
    version = "8.0.7";

    src = fetchgit {
      url = "https://git.proxmox.com/git/${pname}.git";
      rev = "ec2fb1da5801b03e2bd2714f9a41fa4322f6ba61";
      hash = "sha256-uRcZuF7p2wCVRflJy4CxwDzKF6IS3uMGiN+iL227taU=";
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
      "PERL_VENDORARCH=${perl536.libPrefix}/${perl536.version}"
      "PVEDIR=$(out)/${perl536.libPrefix}/${perl536.version}/PVE"
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
              corosync
              libfaketime
            ]
          } \
          --prefix PERL5LIB : $out/${perl536.libPrefix}/${perl536.version}
      done      
    '';

    passthru.updateScript = [
      ../update.sh
      pname
      src.url
    ];

    meta = with lib; {
      description = "Cluster FS and Tools";
      homepage = "https://github.com/proxmox/pve-cluster";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
