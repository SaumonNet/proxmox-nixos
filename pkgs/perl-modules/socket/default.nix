{
  lib,
  fetchurl,
  perl538,
}:

perl538.pkgs.buildPerlPackage rec {
  pname = "Socket";
  version = "2.040";

  src = fetchurl {
    url = "mirror://cpan/authors/id/P/PE/PEVANS/Socket-${version}.tar.gz";
    hash = "sha256-vgEC/c6o1D8bAu8u+UNFrEu8e2xm7OLd0aNZPYNxuhs=";
  };

  passthru.updateScript = [
    ../update.pl
    "Socket"
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
