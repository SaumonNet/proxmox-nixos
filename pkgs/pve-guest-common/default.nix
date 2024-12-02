{
  lib,
  stdenv,
  fetchgit,
  perl538,
}:

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-guest-common";
    version = "5.1.6";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "4c2dd7c226ee3268bc144bbb9b639637f0981ff2";
      hash = "sha256-NbJBKb4az62esyb8D3iMw+3I5U+XnfEyaK0XQxu5hv8=";
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
