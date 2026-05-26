{
  lib,
  stdenv,
  fetchgit,
  perl5,
  acme-sh,
  bash,
  curl,
  pve-update-script,
}:

let
  perlDeps = with perl5.pkgs; [
    HTTPDaemon
    HTTPMessage
  ];
in

perl5.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "proxmox-acme";
    version = "1.7.1";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "64391655acef5ef5a38ca3f9968f8ff31dca0a98";
      hash = "sha256-r1dMqmuVTlNuEowrV1QgrV2Q4/h5BLtFUMbXxwngEmQ=";
    };

    sourceRoot = "${src.name}/src";

    postPatch = ''
      # Remove --reset-env so basic coreutils tools could be found
      substituteInPlace PVE/ACME/DNSChallenge.pm \
        --replace-fail "--reset-env" "" \
        --replace-fail '/bin/bash' '${lib.getExe bash}'
      substituteInPlace proxmox-acme \
        --replace-fail '_CURL="curl' '_CURL="${lib.getExe curl}' 

      sed -i Makefile -e "s,acme.sh,${acme-sh}/libexec,"
    '';

    makeFlags = [
      "PREFIX=$(out)"
      "PERLDIR=$(out)/${perl5.libPrefix}/${perl5.version}"
    ];

    propagatedBuildInputs = perlDeps;

    postFixup = ''
      find $out -type f | xargs sed -i -e "s|/usr/share/proxmox-acme|$out/share/proxmox-acme|"
    '';

    passthru.updateScript = pve-update-script {
      extraArgs = [
        "--deb-name"
        "libproxmox-acme-perl"
        "--use-git-log"
      ];
    };

    meta = with lib; {
      description = "ACME library and helpers for perl-based Proxmox projects";
      homepage = "https://git.proxmox.com/?p=proxmox-acme.git";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
