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
    version = "1.6.6";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "a2b0e828b9e260990469d81f7f24d902ddb6c2a2";
      hash = "sha256-5Cv0ZI6we+yB/qTBmklDE03TbYzTYn56tNwTfaFo2b4=";
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
