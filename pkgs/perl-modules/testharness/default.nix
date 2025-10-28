{
  lib,
  fetchurl,
  perl540,
}:

perl540.pkgs.buildPerlPackage rec {
  pname = "TestHarness";
  version = "3.52";

  src = fetchurl {
    url = "mirror://cpan/authors/id/L/LE/LEONT/Test-Harness-${version}.tar.gz";
    hash = "sha256-j+Zc/AJh7TyKQ5XwUkKG9XGWaf4wX5sDsWzzaE1izXA=";
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
