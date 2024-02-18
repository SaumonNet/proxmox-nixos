{ lib
, stdenv
, fetchFromGitHub
, callPackage
, perl
}:

let
  perlDeps = with perl.pkgs; with callPackage ../perl-packages.nix { }; [ IOSocketSSL ];
in

perl.pkgs.toPerlModule (stdenv.mkDerivation {
  pname = "pve-apiclient";
  version = "3.3.1";

  src = fetchFromGitHub {
    owner = "proxmox";
    repo = "pve-apiclient";
    rev = "dfee5e09acd529f28c7565f380f2dd3415cd92e7";
    hash = "sha256-uIz0G4thjsa48QmQMMkgZ6Uh9yJTY1WPKLYReOWoKVM=";
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
