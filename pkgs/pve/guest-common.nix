{ lib
, stdenv
, fetchFromGitHub
, perl
}:

perl.pkgs.toPerlModule (stdenv.mkDerivation rec {
  pname = "pve-guest-common";
  version = "5.0.3";

  src = fetchFromGitHub {
    owner = "proxmox";
    repo = "pve-guest-common";
    rev = "831a2fffb226de038d64a5f7ba90a826678a9a32";
    hash = "sha256-1sVbCXxpllgjI4Moeud5XyJVfuQt4W5UATPgcJf8eiQ=";
  };

  sourceRoot = "source/src";

  makeFlags = [
    "PERL5DIR=$(out)/${perl.libPrefix}/${perl.version}"
    "DOCDIR=$(out)/share/doc/${pname}"
  ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/proxmox/pve-guest-common";
    license = with licenses; [ ];
    maintainers = with maintainers; [ camillemndn julienmalka ];
    platforms = platforms.linux;
  };
})
