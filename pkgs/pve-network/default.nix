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
    version = "1.1.8";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "3938fa1c6e88cc9d8eebcd8ba1919a5417e109e0";
      hash = "sha256-A5PZTudip6mGqi0TcHAX7+bh0htGjzqza6NLNvhjPp4=";
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
