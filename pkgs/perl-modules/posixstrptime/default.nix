{
  lib,
  fetchurl,
  perl538,
}:

perl538.pkgs.buildPerlPackage rec {
  pname = "POSIXstrptime";
  version = "0.13";

  src = fetchurl {
    url = "mirror://cpan/authors/id/G/GO/GOZER/POSIX-strptime-${version}.tar.gz";
    hash = "sha256-qBgQmCnjWkrHlnfWgGOGX0DIfJnKfzogiQF3qPjlwnc=";
  };

  passthru.updateScript = [
    ../update.pl
    "POSIX::strptime"
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
