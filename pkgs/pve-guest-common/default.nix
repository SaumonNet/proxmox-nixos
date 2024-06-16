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
      url = "https://git.proxmox.com/git/${pname}.git";
      rev = "a9604f72ebe6d9c5ca3c7d9eebb9b0fc31d063d0";
      hash = "sha256-Vv2tIP8TCDUvbRcw90K4Ilg5wVxbKlV4SZgPjUJO5iI=";
    };

    sourceRoot = "${src.name}/src";

    makeFlags = [
      "PERL5DIR=$(out)/${perl536.libPrefix}/${perl536.version}"
      "DOCDIR=$(out)/share/doc/${pname}"
    ];

    passthru.updateScript = [
      ../update.sh
      pname
      src.url
    ];

    meta = with lib; {
      description = "";
      homepage = "https://github.com/proxmox/pve-guest-common";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
