{
  lib,
  stdenv,
  fetchgit,
  perl538,
}:

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-guest-common";
    version = "5.2.2";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "58ad1835bf48ac8a62877cc8889c67b49330113f";
      hash = "sha256-vKm8C5cAHaU0LRb9AYM1wyYrfeY1R7Z8HuZ7qgfeQCw=";
    };

    sourceRoot = "${src.name}/src";

    makeFlags = [
      "PERL5DIR=$(out)/${perl538.libPrefix}/${perl538.version}"
      "DOCDIR=$(out)/share/doc/${pname}"
    ];

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
    ];

    meta = with lib; {
      description = "Proxmox VE guest-related modules";
      homepage = "git://git.proxmox.com/?p=pve-guest-common.git";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
