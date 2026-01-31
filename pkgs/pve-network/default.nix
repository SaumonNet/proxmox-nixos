{
  lib,
  stdenv,
  fetchgit,
  makeWrapper,
  netsubnet,
  perl540,
  pve-access-control,
  pve-common,
  pve-cluster,
  pve-rs,
  pkg-config,
  uuid,
  pve-update-script,
}:

let
  perlDeps = with perl540.pkgs; [
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
  perlEnv = perl540.withPackages (_: perlDeps);
in

perl540.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-network";
    version = "1.2.4";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "3d9449686cd4a3427dda3e3ef9430b7630c3555b";
      hash = "sha256-AJpxwrpGiOJl4LCGQcHzfD7hzdJN+2giI5JkY4Xmhls=";
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
      "PERL5DIR=$(out)/${perl540.libPrefix}/${perl540.version}"
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
