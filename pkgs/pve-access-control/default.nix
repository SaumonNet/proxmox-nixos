{
  lib,
  stdenv,
  fetchgit,
  perl,
  pve-common,
}:

let
  perlDeps = with perl.pkgs; [
    authenpam
    pve-common
  ];

  perlEnv = perl.withPackages (_: perlDeps);
in

perl.pkgs.toPerlModule (
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
      "PERLDIR=/${perl.libPrefix}/${perl.version}"
    ];

    meta = with lib; {
      description = "Access control framework";
      homepage = "https://github.com/proxmox/pve-access-control";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
