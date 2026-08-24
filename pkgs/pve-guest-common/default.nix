{
  lib,
  stdenv,
  fetchgit,
  perl5,
  pve-update-script,
}:

perl5.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-guest-common";
    version = "6.0.5";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "191c23e385e5dbed1938b2d1d322196831ef9331";
      hash = "sha256-6ha53cfISILeHn9Oe9yKRG+YA5/oJCqd43kep4rs6Hc=";
    };

    sourceRoot = "${src.name}/src";

    makeFlags = [
      "PERL5DIR=$(out)/${perl5.libPrefix}/${perl5.version}"
      "DOCDIR=$(out)/share/doc/${pname}"
    ];

    passthru.updateScript = pve-update-script {
      extraArgs = [
        "--deb-name"
        "libpve-guest-common-perl"
        "--use-git-log"
      ];
    };

    meta = with lib; {
      description = "Proxmox VE guest-related modules";
      homepage = "https://git.proxmox.com/?p=pve-guest-common.git";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
