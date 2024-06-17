{
  lib,
  fetchurl,
  perl536,
}:

perl536.pkgs.buildPerlPackage rec {
  pname = "TestHarness";
  version = "3.48";

  src = fetchurl {
    url = "mirror://cpan/authors/id/L/LE/LEONT/Test-Harness-${version}.tar.gz";
    hash = "sha256-5z/4nIHBpT9rru9oFoQbidM4RAOtl0IqfanR7rIO+cU=";
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
