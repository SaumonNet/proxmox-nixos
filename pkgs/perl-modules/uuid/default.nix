{
  lib,
  fetchurl,
  perl536,
  libuuid,
}:

perl536.pkgs.buildPerlPackage rec {
  pname = "UUID";
  version = "0.35";

  src = fetchurl {
    url = "mirror://cpan/authors/id/J/JR/JRM/UUID-${version}.tar.gz";
    hash = "sha256-Qa5IhIIP8p7rPs9UKhbveqtoclDElW2Hbp5wqIrG3M8=";
  };

  buildInputs = [
    perl536.pkgs.DevelChecklib
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
