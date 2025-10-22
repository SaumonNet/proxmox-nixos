{
  lib,
  stdenv,
  fetchgit,
  perl538,
  acme-sh,
  bash,
  curl,  
}:

let
  perlDeps = with perl538.pkgs; [
    HTTPDaemon
    HTTPMessage
  ];
in

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "proxmox-acme";
    version = "1.6.0";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "245c99f2a8049682a1a80733655140129a616342";
      hash = "sha256-e4BkUeQ9AGaUvjN2c5zZvSW1z/9u4lq4HOFyWPgzHwE=";
    };

    sourceRoot = "${src.name}/src";

    postPatch = ''
      # Remove --reset-env so basic coreutils tools could be found
      substituteInPlace PVE/ACME/DNSChallenge.pm \
        --replace-fail ', "--reset-env"' "" \
        --replace-fail '/bin/bash' '${lib.getExe bash}'
      substituteInPlace proxmox-acme \
        --replace-fail '_CURL="curl' '_CURL="${lib.getExe curl}' 

      sed -i Makefile -e "s,acme.sh,${acme-sh}/libexec,"
    '';

    makeFlags = [
      "PREFIX=$(out)"
      "PERLDIR=$(out)/${perl538.libPrefix}/${perl538.version}"
    ];

    propagatedBuildInputs = perlDeps;

    postFixup = ''
      find $out -type f | xargs sed -i -e "s|/usr/share/proxmox-acme|$out/share/proxmox-acme|"
    '';

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
    ];

    meta = with lib; {
      description = "ACME library and helpers for perl-based Proxmox projects";
      homepage = "git://git.proxmox.com/?p=proxmox-acme.git";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
