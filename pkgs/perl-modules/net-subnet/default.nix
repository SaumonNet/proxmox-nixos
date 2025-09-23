{
  lib,
  fetchurl,
  perl538,
}:

perl538.pkgs.buildPerlPackage rec {
  pname = "NetSubnet";
  version = "1.03";

  src = fetchurl {
    url = "mirror://cpan/authors/id/J/JU/JUERD/Net-Subnet-${version}.tar.gz";
    hash = "sha256-El5ttkyYAmQ5+bWFEV+U9CMVox2PFspj0Mk5q2YBmvo=";
  };

  passthru.updateScript = [
    ../update.pl
    "NetSubnet"
  ];

  meta = with lib; {
    description = "Fast IP-in-subnet matcher for IPv4 and IPv6, CIDR or mask";
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
