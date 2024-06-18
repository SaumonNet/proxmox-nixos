{
  lib,
  stdenv,
  fetchgit,
  perl536,
  pve-common,
  authenpam,
}:

let
  perlDeps = with perl536.pkgs; [
    authenpam
    pve-common
  ];

  perlEnv = perl536.withPackages (_: perlDeps);
in

perl536.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-access-control";
    version = "8.1.4";

    src = fetchgit {
      url = "https://git.proxmox.com/git/${pname}.git";
      rev = "2c74a9abd5e34764c3ac16af1845eecb2dadf1af";
      hash = "sha256-yY9WQ47K+pezcJ1auHvDjAgXQ6LKxLAcH65+jy/D4qc=";
    };

    sourceRoot = "${src.name}/src";

    postPatch = ''
      sed -i Makefile \
        -e "s/pveum.1 oathkeygen pveum.bash-completion pveum.zsh-completion/oathkeygen/" \
        -e "/pveum.1/,+2d"
    '';

    buildInputs = [ perlEnv ];
    propagatedBuildInputs = perlDeps;
    dontPatchShebangs = true;

    makeFlags = [
      "DESTDIR=$(out)"
      "PREFIX="
      "SBINDIR=/.bin"
      "BINDIR=/.bin"
      "PERLDIR=/${perl536.libPrefix}/${perl536.version}"
    ];

    passthru.updateScript = [
      ../update.sh
      pname
      src.url
    ];

    meta = with lib; {
      description = "Proxmox VE Access control framework";
      homepage = "https://git.proxmox.com/?p=pve-access-control.git";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
