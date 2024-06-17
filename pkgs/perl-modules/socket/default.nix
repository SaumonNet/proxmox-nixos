{
  lib,
  fetchurl,
  perl536,
}:

perl536.pkgs.buildPerlPackage rec {
  pname = "Socket";
  version = "2.037";

  src = fetchurl {
    url = "mirror://cpan/authors/id/P/PE/PEVANS/Socket-${version}.tar.gz";
    hash = "sha256-hUSIEenidDdEBGNPPCCK+pNu5NIj52JR6phoMVsMgS8=";
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
