{
  lib,
  stdenv,
  fetchgit,
  perl5,
  acme-sh,
  bash,
  curl,
  bind,
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
    version = "1.7.2";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "2fdd0fcce3d11bf9cf623e48a651c375478aedbc";
      hash = "sha256-uXQ8YvMSgqWYf9tnpPyXu9iEA40YfQcETUpEuoCjdvM=";
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
      substituteInPlace $out/share/proxmox-acme/dnsapi/dns_nsupdate.sh \
        --replace-fail "    nsupdate" "    ${lib.getExe' bind.dnsutils "nsupdate"}"
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
