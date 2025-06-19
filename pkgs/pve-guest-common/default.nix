{
  lib,
  stdenv,
  fetchgit,
  perl538,
}:

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-guest-common";
    version = "6.0.0";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "531097338bc0900816cab34f35e24ef8744d3ed0";
      hash = "sha256-N453cgr04fVh8g0yJrWa2RcnSmD+oFIdUpyK9Pb/Cls=";
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
