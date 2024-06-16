{
  lib,
  fetchurl,
  perl536,
}:
perl536.pkgs.buildPerlPackage rec {
  pname = "MIMEBase64";
  version = "3.16";
  src = fetchurl {
    url = "mirror://cpan/authors/id/C/CA/CAPOEIRAB/MIME-Base64-${version}.tar.gz";
    hash = "sha256-d/c9b3rrjTO+CLDYwmF/m2x3+3/EVCLVB8qLr+QkYBc=";
  };
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
