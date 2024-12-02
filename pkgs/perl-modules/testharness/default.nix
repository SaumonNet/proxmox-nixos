{
  lib,
  fetchurl,
  perl538,
}:

perl538.pkgs.buildPerlPackage rec {
  pname = "TestHarness";
  version = "3.50";

  src = fetchurl {
    url = "mirror://cpan/authors/id/L/LE/LEONT/Test-Harness-${version}.tar.gz";
    hash = "sha256-ebas3ERPGSTNTC6e2Gi9xuCVgAIayo/weO3i/++Kb1Q=";
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
