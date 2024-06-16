{
  lib,
  fetchurl,
  perl536,
}:
perl536.pkgs.buildPerlPackage rec {
  pname = "FindBin";
  version = "1.53";
  src = fetchurl {
    url = "mirror://cpan/authors/id/T/TO/TODDR/FindBin-${version}.tar.gz";
    hash = "sha256-ts+vJAdYeA3jxpw5liMPaSpUNuA7Jq4CCFK4K1JyEkU=";
  };
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
