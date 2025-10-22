{
  lib,
  fetchurl,
  perl538,
}:
perl538.pkgs.buildPerlPackage rec {
  pname = "FindBin";
  version = "1.54";
  src = fetchurl {
    url = "mirror://cpan/authors/id/T/TO/TODDR/FindBin-${version}.tar.gz";
    hash = "sha256-ascyln5Sn+N2lZre7uJ2Dmli16nYXnlti2peHNjykV0=";
  };

  passthru.updateScript = [
    ../update.pl
    "FindBin"
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
