{
  lib,
  stdenv,
  fetchgit,
  perl,
  acme-sh,
}:

let
  perlDeps = with perl.pkgs; [
    HTTPDaemon
    HTTPMessage
  ];
in

perl.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "proxmox-acme";
    version = "1.4.6";

    src = fetchgit {
      url = "https://git.proxmox.com/git/${pname}.git";
      rev = "c0e3e6c415cb6a6740a3718a0ab744df38bae152";
      hash = "sha256-5JZc7NarnwPmAYEQ4NznZGHWHnNxwx3av9Ehz/+Ua4M=";
    };

    sourceRoot = "${src.name}/src";

    postPatch = ''
      sed -i Makefile -e "s,acme.sh,${acme-sh}/libexec,"
    '';

    makeFlags = [
      "PREFIX=$(out)"
      "PERLDIR=$(out)/${perl.libPrefix}/${perl.version}"
    ];

    propagatedBuildInputs = perlDeps;

    postFixup = ''
      find $out -type f | xargs sed -i -e "s|/usr/share/proxmox-acme|$out/share/proxmox-acme|"
    '';

    passthru.updateScript = [
      ../update.sh
      pname
      src.url
    ];

    meta = with lib; {
      description = "";
      homepage = "git://git.proxmox.com/git/proxmox-acme.git";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
