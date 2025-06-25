{
  lib,
  fetchurl,
  perl538,
}:

perl538.pkgs.buildPerlPackage rec {
  pname = "Socket";
  version = "2.039";

  src = fetchurl {
    url = "mirror://cpan/authors/id/P/PE/PEVANS/Socket-${version}.tar.gz";
    hash = "sha256-XcYa5uBJ5Q0QUtZWNBtgkdyfiERkp44q/cK5if9DkLs=";
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
