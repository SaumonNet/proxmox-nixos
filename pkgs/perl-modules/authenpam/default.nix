{
  lib,
  fetchurl,
  linux-pam,
  perl540,
}:

perl540.pkgs.buildPerlPackage rec {
  pname = "AuthenPAM";
  version = "0.16";

  src = fetchurl {
    url = "mirror://cpan/authors/id/N/NI/NIKIP/Authen-PAM-${version}.tar.gz";
    hash = "sha256-DpSb2aKp3w+CmXEDD+kWnLr2zseLkvryL1R/9sYVXJs=";
  };

  buildInputs = [ linux-pam ];
  setOutputFlags = false;
  doCheck = false;

  passthru.updateScript = [
    ../update.pl
    "Authen::PAM"
  ];

  meta = with lib; {
    description = "Perl interface to PAM library";
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
