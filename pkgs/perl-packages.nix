{ lib, pkgs, fetchurl, perl }:

with perl.pkgs;

{
  AuthenPAM = buildPerlPackage rec {
    pname = "AuthenPAM";
    version = "0.16";
    src = fetchurl {
      url = "mirror://cpan/authors/id/N/NI/NIKIP/Authen-PAM-${version}.tar.gz";
      hash = "sha256-DpSb2aKp3w+CmXEDD+kWnLr2zseLkvryL1R/9sYVXJs=";
    };
    buildInputs = [ pkgs.linux-pam ];
    setOutputFlags = false;
    doCheck = false;
    meta = with lib; {
      description = "Perl interface to PAM library";
      license = with licenses; [ artistic1 gpl1Plus ];
      maintainers = with maintainers; [ camillemndn julienmalka ];
    };
  };

  DataDumper = buildPerlPackage rec {
    pname = "DataDumper";
    version = "2.183";
    src = fetchurl {
      url = "mirror://cpan/authors/id/N/NW/NWCLARK/Data-Dumper-${version}.tar.gz";
      hash = "sha256-5Cc2iQt9rhs3gY2cXvofH9xS3sBPRGozpIGb8dSrWtM=";
    };
    meta = with lib; {
      description = "stringified perl data structures, suitable for both printing and eval";
      license = with licenses; [ artistic1 gpl1Plus ];
      maintainers = with maintainers; [ camillemndn julienmalka ];
    };
  };

  DigestSHA = buildPerlPackage rec {
    pname = "DigestSHA";
    version = "6.04";
    src = fetchurl {
      url = "mirror://cpan/authors/id/M/MS/MSHELOR/Digest-SHA-${version}.tar.gz";
      hash = "sha256-7pH499uJTufG7gA9qsEKmQVsSUimdO9GrNu2PIGkq+s=";
    };
    meta = with lib; {
      description = "Perl extension for SHA-1/224/256/384/512";
      license = with licenses; [ artistic1 gpl1Plus ];
      maintainers = with maintainers; [ camillemndn julienmalka ];
    };
  };

  FindBin = buildPerlPackage rec {
    pname = "FindBin";
    version = "1.53";
    src = fetchurl {
      url = "mirror://cpan/authors/id/T/TO/TODDR/FindBin-${version}.tar.gz";
      hash = "sha256-ts+vJAdYeA3jxpw5liMPaSpUNuA7Jq4CCFK4K1JyEkU=";
    };
    meta = with lib; {
      description = "Base32 encoder and decoder";
      license = with licenses; [ artistic1 gpl1Plus ];
      maintainers = with maintainers; [ camillemndn julienmalka ];
    };
  };

  IOSocketIP = buildPerlModule rec {
    pname = "IOSocketIP";
    version = "0.41";
    src = fetchurl {
      url = "mirror://cpan/authors/id/P/PE/PEVANS/IO-Socket-IP-${version}.tar.gz";
      hash = "sha256-hJpFojj4OSWIuXciyFA4LE5tFXzQioIt3LkHPHO/FEY=";
    };
    meta = with lib; {
      description = "Base32 encoder and decoder";
      license = with licenses; [ artistic1 gpl1Plus ];
      maintainers = with maintainers; [ camillemndn julienmalka ];
    };
  };

  MIMEBase32 = buildPerlPackage rec {
    pname = "MIMEBase32";
    version = "1.303";
    src = fetchurl {
      url = "mirror://cpan/authors/id/R/RE/REHSACK/MIME-Base32-${version}.tar.gz";
      hash = "sha256-qyH6mRMOM6Cv9s21lvZH5eVl0gfWNLou8Gvb71BCTpk=";
    };
    propagatedBuildInputs = [ Exporter ];
    meta = with lib; {
      description = "Base32 encoder and decoder";
      license = with licenses; [ artistic1 gpl1Plus ];
      maintainers = with maintainers; [ camillemndn julienmalka ];
    };
  };

  MIMEBase64 = buildPerlPackage rec {
    pname = "MIMEBase64";
    version = "3.16";
    src = fetchurl {
      url = "mirror://cpan/authors/id/C/CA/CAPOEIRAB/MIME-Base64-${version}.tar.gz";
      hash = "sha256-d/c9b3rrjTO+CLDYwmF/m2x3+3/EVCLVB8qLr+QkYBc=";
    };
    meta = with lib; {
      description = "Base32 encoder and decoder";
      license = with licenses; [ artistic1 gpl1Plus ];
      maintainers = with maintainers; [ camillemndn julienmalka ];
    };
  };

  POSIXstrptime = buildPerlPackage rec {
    pname = "POSIXstrptime";
    version = "0.13";
    src = fetchurl {
      url = "mirror://cpan/authors/id/G/GO/GOZER/POSIX-strptime-${version}.tar.gz";
      hash = "sha256-qBgQmCnjWkrHlnfWgGOGX0DIfJnKfzogiQF3qPjlwnc=";
    };
    meta = with lib; {
      description = "Base32 encoder and decoder";
      license = with licenses; [ artistic1 gpl1Plus ];
      maintainers = with maintainers; [ camillemndn julienmalka ];
    };
  };

  Socket = buildPerlPackage rec {
    pname = "Socket";
    version = "2.037";
    src = fetchurl {
      url = "mirror://cpan/authors/id/P/PE/PEVANS/Socket-${version}.tar.gz";
      hash = "sha256-hUSIEenidDdEBGNPPCCK+pNu5NIj52JR6phoMVsMgS8=";
    };
    meta = with lib; {
      description = "Base32 encoder and decoder";
      license = with licenses; [ artistic1 gpl1Plus ];
      maintainers = with maintainers; [ camillemndn julienmalka ];
    };
  };

  TestHarness = buildPerlPackage rec {
    pname = "TestHarness";
    version = "3.44";
    src = fetchurl {
      url = "mirror://cpan/authors/id/L/LE/LEONT/Test-Harness-${version}.tar.gz";
      hash = "sha256-frWR6mtJns5nRf8+gOYM7mafADf5zLxORRFCX1k+Upc=";
    };
    doCheck = false;
    meta = with lib; {
      description = "Run test scripts with statistics";
      license = with licenses; [ artistic1 gpl1Plus ];
      maintainers = with maintainers; [ camillemndn julienmalka ];
    };
  };

  TermReadLine = buildPerlPackage rec {
    pname = "TermReadLine";
    version = "1.14";
    src = fetchurl {
      url = "mirror://cpan/authors/id/F/FL/FLORA/Term-ReadLine-${version}.tar.gz";
      hash = "sha256-VFI8crJqBGCBcISQE6QzukAPZrT5sFJCAb/Tf/bjxHc=";
    };
    meta = with lib; {
      description = "Perl interface to various readline packages";
      license = with licenses; [ artistic1 gpl1Plus ];
      maintainers = with maintainers; [ camillemndn julienmalka ];
    };
  };

  UUID = buildPerlPackage rec {
    pname = "UUID";
    version = "0.28";
    src = fetchurl {
      url = "mirror://cpan/authors/id/J/JR/JRM/UUID-${version}.tar.gz";
      hash = "sha256-pcFz+tqXPfCVvQWVmjljvySv1/7w/RiE7/WJyowXu34=";
    };
    buildInputs = [ DevelChecklib pkgs.libuuid.dev ];
    NIX_CFLAGS_LINK = "-luuid";
    meta = with lib; {
      description = "DCE compatible Universally Unique Identifier library";
      license = with licenses; [ artistic1 gpl1Plus ];
      maintainers = with maintainers; [ camillemndn julienmalka ];
    };
  };
}
