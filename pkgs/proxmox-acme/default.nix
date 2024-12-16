{
  lib,
  stdenv,
  fetchgit,
  perl538,
  acme-sh,
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
    version = "1.5.1";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "bb6df0b8185829b5c1757330c12f977e196ed2b8";
      hash = "sha256-yVgOOE7vAEc9PFeAUuqnctdkWdXLYnDD/gra8YDGhq0=";
    };

    sourceRoot = "${src.name}/src";

    postPatch = ''
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
