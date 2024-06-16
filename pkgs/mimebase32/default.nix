{
  lib,
  fetchurl,
  perl536,
}:

perl536.pkgs.buildPerlPackage rec {
  pname = "MIMEBase32";
  version = "1.303";
  src = fetchurl {
    url = "mirror://cpan/authors/id/R/RE/REHSACK/MIME-Base32-${version}.tar.gz";
    hash = "sha256-qyH6mRMOM6Cv9s21lvZH5eVl0gfWNLou8Gvb71BCTpk=";
  };
  propagatedBuildInputs = [ perl536.pkgs.Exporter ];
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
