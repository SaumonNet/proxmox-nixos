{
  lib,
  stdenv,
  fetchgit,
  perl540,
  acme-sh,
  bash,
  curl,
  pve-update-script,
}:

let
  perlDeps = with perl540.pkgs; [
    HTTPDaemon
    HTTPMessage
  ];
in

perl540.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "proxmox-acme";
    version = "1.7.0";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "6dc96d5a468d1553991589f4197f9ec6eab554c1";
      hash = "sha256-4P1Zw5zBsxOyy0b5Blbsg/k8dzdnz0xvXxuS5JKT5Cw=";
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
      "PERLDIR=$(out)/${perl540.libPrefix}/${perl540.version}"
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
