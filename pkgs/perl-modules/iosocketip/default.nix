{
  lib,
  fetchurl,
  perl536,
}:

perl536.pkgs.buildPerlModule rec {
  pname = "IOSocketIP";
  version = "0.42";

  src = fetchurl {
    url = "mirror://cpan/authors/id/P/PE/PEVANS/IO-Socket-IP-${version}.tar.gz";
    hash = "sha256-+Xo4RsUKTgZYzhciznzCrK2UcucEeL++nHlPsdtqaxM=";
  };

  passthru.updateScript = [
    ../update.pl
    "IO::Socket::IP"
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
