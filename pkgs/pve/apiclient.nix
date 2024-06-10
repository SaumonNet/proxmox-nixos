{ lib
, stdenv
, fetchgit
, callPackage
, perl
}:

let
  perlDeps = with perl.pkgs; with callPackage ../perl-packages.nix { }; [ IOSocketSSL ];
in

perl.pkgs.toPerlModule (stdenv.mkDerivation rec {
  pname = "pve-apiclient";
  version = "3.3.2";

  src = fetchgit {
    url = "https://git.proxmox.com/git/${pname}.git";
    rev = "94d38f0aba67ad04bf20159f605d5f7380cf7b58";
    hash = "sha256-wCPCEx8SpGpcuYDV2InobN9bcBu0RUlzcpD6sgmm/Wg=";
  };

  sourceRoot = "source/src";

  makeFlags = [
    "PERL5DIR=$(out)/${perl.libPrefix}/${perl.version}"
    "DOCDIR=$(out)/share/doc"
  ];

  propagatedBuildInputs = perlDeps;

  meta = with lib; {
    description = "Read-Only mirror of perl API client library";
    homepage = "https://github.com/proxmox/pve-apiclient";
    license = with licenses; [ ];
    maintainers = with maintainers; [ camillemndn julienmalka ];
    platforms = platforms.linux;
  };
})
