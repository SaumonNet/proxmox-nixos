{
  lib,
  fetchurl,
  perl536,
}:

perl536.pkgs.buildPerlPackage rec {
  pname = "TermReadLine";
  version = "1.14";

  src = fetchurl {
    url = "mirror://cpan/authors/id/F/FL/FLORA/Term-ReadLine-${version}.tar.gz";
    hash = "sha256-VFI8crJqBGCBcISQE6QzukAPZrT5sFJCAb/Tf/bjxHc=";
  };

  passthru.updateScript = [
    ../update.pl
    "Term::ReadLine"
  ];

  meta = with lib; {
    description = "Perl interface to various readline packages";
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
