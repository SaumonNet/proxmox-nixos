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
    version = "6.0.3";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "572ed3533d5ba75e82a5a0e367e2db1aff290c09";
      hash = "sha256-1fOaFcyvIBBqj8ka38KoOt/8hnNoohF8jnIPWiToU/k=";
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
