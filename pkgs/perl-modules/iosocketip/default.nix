{
  lib,
  fetchurl,
  perl538,
}:

perl538.pkgs.buildPerlModule rec {
  pname = "IOSocketIP";
  version = "0.43";

  src = fetchurl {
    url = "mirror://cpan/authors/id/P/PE/PEVANS/IO-Socket-IP-${version}.tar.gz";
    hash = "sha256-6/Yhf0j1N66aeBJvDstLqj1IIOPiYVPOJQ87/9BfbQs=";
  };

  doCheck = false;

  passthru.updateScript = [
    ../update.pl
    "IO::Socket::IP"
  ];

  meta = with lib; {
    description = "Base32 encoder and decoder";
    license = with licenses; [
      artistic1
      gpl1Plus
    ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
  };
}
