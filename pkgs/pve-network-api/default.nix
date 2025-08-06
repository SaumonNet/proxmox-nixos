{
  lib,
  stdenv,
  makeWrapper,
  perl538,
  pkg-config,
  pve-cluster,
  pve-common,
  pve-firewall,
  pve-network,
}:

let
  perlDeps = [ 
    pve-common
    pve-cluster
    pve-firewall
    pve-network
  ];
  perlEnv = perl538.withPackages (_: perlDeps);
in

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-network-api";

    inherit (pve-network) version src;

    sourceRoot = "${src.name}/src/PVE/API2";

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
      description = "API endpoints for Proxmox VE's SDN stack";
      inherit (pve-network.meta) homepage license platforms;
      maintainers = with maintainers; [ codgician ];
    };
  }
)
