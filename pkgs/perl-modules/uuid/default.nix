{
  lib,
  fetchurl,
  perl536,
  libuuid,
}:

perl536.pkgs.buildPerlPackage rec {
  pname = "UUID";
  version = "0.28";
  src = fetchurl {
    url = "mirror://cpan/authors/id/J/JR/JRM/UUID-${version}.tar.gz";
    hash = "sha256-pcFz+tqXPfCVvQWVmjljvySv1/7w/RiE7/WJyowXu34=";
  };
  buildInputs = [
    perl536.pkgs.DevelChecklib
    libuuid.dev
  ];
  NIX_CFLAGS_LINK = "-luuid";
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
