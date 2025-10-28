{
  lib,
  fetchurl,
  perl540,
}:

perl540.pkgs.buildPerlPackage rec {
  pname = "DigestSHA";
  version = "6.04";

  src = fetchurl {
    url = "mirror://cpan/authors/id/M/MS/MSHELOR/Digest-SHA-${version}.tar.gz";
    hash = "sha256-7pH499uJTufG7gA9qsEKmQVsSUimdO9GrNu2PIGkq+s=";
  };

  passthru.updateScript = [
    ../update.pl
    "Digest::SHA"
  ];

  meta = with lib; {
    description = "Perl extension for SHA-1/224/256/384/512";
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
