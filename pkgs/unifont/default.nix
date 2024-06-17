{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "unifont";
  version = "15.1.05";

  src = fetchurl {
    url = "mirror://gnu/unifont/unifont-${version}/unifont-${version}.tar.gz";
    hash = "sha256-0nX1X0NYdQ4PhjBbkuh7iOszCqRsFfVT0u3wR/scI/o=";
  };

  makeFlags = [
    "USRDIR=."
    "DESTDIR=$(out)"
  ];

  meta = with lib; {
    description = "";
    homepage = "https://unifoundry.com/unifont/";
    license = [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.all;
  };
}
