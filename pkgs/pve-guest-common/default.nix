{
  lib,
  stdenv,
  fetchgit,
  perl538,
}:

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-guest-common";
    version = "5.1.7";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "90edabc8168ce685ede004abcf93f12795832ba9";
      hash = "sha256-7R56F0zg9q0B+STbFs/csxH3YYtb2hKqkFYRF9hRWwA=";
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
