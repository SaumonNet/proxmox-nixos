{
  lib,
  stdenv,
  fetchgit,
  makeWrapper,
  net-subnet,
  perl538,
  pve-access-control,
  pve-common,
  pve-cluster,
  pve-rs,
  pkg-config,
  uuid,
}:

let
  perlDeps = with perl538.pkgs; [ 
    IOSocketSSL
    NetAddrIP
    NetIP
    net-subnet
    uuid
    pve-access-control
    pve-common
    pve-cluster
    pve-rs
  ];
  perlEnv = perl538.withPackages (_: perlDeps);
in

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-network";
    version = "0.11.2";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "8f4f5d2074989cf814d2f2312360239377c495f5";
      hash = "sha256-bJp432j3wC4cRgti9YE+cNFxFcHp6HR0f7yZzFWBqHQ=";
    };

    sourceRoot = "${src.name}/src/PVE/Network";

    buildInputs = [
      pkg-config
      perlEnv
      makeWrapper
    ];

    propagatedBuildInputs = perlDeps;

    makeFlags = [
      "DESTDIR=$(out)"
      "PERL5DIR=$(out)/${perl538.libPrefix}/${perl538.version}"
    ];

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
    ];

    meta = with lib; {
      description = "Proxmox VE's SDN (Software Defined Network) stack";
      homepage = "git://git.proxmox.com/?p=pve-network.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [ codgician ];
      platforms = platforms.linux;
    };
  }
)
