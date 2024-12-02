{
  lib,
  fetchurl,
  perl538,
  libuuid,
}:

perl538.pkgs.buildPerlPackage rec {
  pname = "UUID";
  version = "0.36";

  src = fetchurl {
    url = "mirror://cpan/authors/id/J/JR/JRM/UUID-${version}.tar.gz";
    hash = "sha256-wYLprYVJgakIA64lOA0hl8pvkjUZ4dUkvIUgXq9JvwY=";
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
