{
  lib,
  stdenv,
  fetchgit,
  perl536,
}:

perl536.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-guest-common";
    version = "5.1.3";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "a9604f72ebe6d9c5ca3c7d9eebb9b0fc31d063d0";
      hash = "sha256-Vv2tIP8TCDUvbRcw90K4Ilg5wVxbKlV4SZgPjUJO5iI=";
    };

    sourceRoot = "${src.name}/src";

    makeFlags = [
      "PERL5DIR=$(out)/${perl536.libPrefix}/${perl536.version}"
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
