{
  lib,
  fetchurl,
  perl538,
}:

perl538.pkgs.buildPerlPackage rec {
  pname = "DataDumper";
  version = "2.183";

  src = fetchurl {
    url = "mirror://cpan/authors/id/N/NW/NWCLARK/Data-Dumper-${version}.tar.gz";
    hash = "sha256-5Cc2iQt9rhs3gY2cXvofH9xS3sBPRGozpIGb8dSrWtM=";
  };

  passthru.updateScript = [
    ../update.pl
    "Data::Dumper"
  ];

  meta = with lib; {
    description = "stringified perl data structures, suitable for both printing and eval";
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
