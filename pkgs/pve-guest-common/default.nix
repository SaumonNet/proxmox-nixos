{
  lib,
  stdenv,
  fetchgit,
  perl536,
}:

perl536.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-guest-common";
    version = "5.1.4";

    src = fetchgit {
      url = "https://git.proxmox.com/git/${pname}.git";
      rev = "58923bbb7aba38acf1fe8455a1e6449435363f3c";
      hash = "sha256-g0DEYgyhu0bqXnnV3sYfc3fV/dj6AV7mex8T5d8OlWA=";
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
