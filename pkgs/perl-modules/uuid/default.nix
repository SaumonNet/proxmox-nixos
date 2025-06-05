{
  lib,
  fetchurl,
  perl538,
  libuuid,
}:

perl538.pkgs.buildPerlPackage rec {
  pname = "UUID";
  version = "0.37";

  src = fetchurl {
    url = "mirror://cpan/authors/id/J/JR/JRM/UUID-${version}.tar.gz";
    hash = "sha256-AvWv4rQ4bgm2yzo5taECt054mj4pcimUogqOMoXFYcc=";
  };

  buildInputs = [
    perl538.pkgs.DevelChecklib
    libuuid.dev
  ];

  NIX_CFLAGS_LINK = "-luuid";
  doCheck = false;

  passthru.updateScript = [
    ../update.pl
    "UUID"
  ];

  meta = with lib; {
    description = "DCE compatible Universally Unique Identifier library";
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
