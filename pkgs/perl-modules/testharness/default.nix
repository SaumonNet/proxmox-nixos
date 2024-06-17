{
  lib,
  fetchurl,
  perl536,
}:

perl536.pkgs.buildPerlPackage rec {
  pname = "TestHarness";
  version = "3.44";

  src = fetchurl {
    url = "mirror://cpan/authors/id/L/LE/LEONT/Test-Harness-${version}.tar.gz";
    hash = "sha256-frWR6mtJns5nRf8+gOYM7mafADf5zLxORRFCX1k+Upc=";
  };

  doCheck = false;

  passthru.updateScript = [
    ../update.pl
    "Test::Harness"
  ];

  meta = with lib; {
    description = "Run test scripts with statistics";
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
