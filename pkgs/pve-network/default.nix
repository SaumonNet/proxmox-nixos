{
  lib,
  stdenv,
  fetchgit,
  makeWrapper,
  netsubnet,
  perl5,
  pve-access-control,
  pve-common,
  pve-cluster,
  pve-rs,
  pkg-config,
  uuid,
  pve-update-script,
}:

let
  perlDeps = with perl5.pkgs; [
    IOSocketSSL
    NetAddrIP
    NetIP
    netsubnet
    uuid
    pve-access-control
    pve-common
    pve-cluster
    pve-rs
  ];
  perlEnv = perl5.withPackages (_: perlDeps);
in

perl5.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-network";
    version = "1.6.7";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "7c6c5d8f53292c311aa07cbdb8e7f59f50af38f5";
      hash = "sha256-Tn7qvsLdEWp43xdZ0qd2sHBhXbrpTiP8PtPOXMg13RA=";
    };

    sourceRoot = "${src.name}/src/PVE";

    buildInputs = [
      pkg-config
      perlEnv
      makeWrapper
    ];

    propagatedBuildInputs = perlDeps;

    makeFlags = [
      "DESTDIR=$(out)"
      "PERL5DIR=$(out)/${perl5.libPrefix}/${perl5.version}"
    ];

    passthru.updateScript = pve-update-script {
      extraArgs = [
        "--deb-name"
        "libpve-network-perl"
      ];
    };

    meta = with lib; {
      description = "Proxmox VE's SDN (Software Defined Network) stack";
      homepage = "https://git.proxmox.com/?p=pve-network.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [ codgician ];
      platforms = platforms.linux;
    };
  }
)
