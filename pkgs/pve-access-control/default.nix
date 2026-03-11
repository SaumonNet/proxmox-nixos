{
  lib,
  stdenv,
  fetchgit,
  perl5,
  pve-common,
  authenpam,
  pve-update-script,
}:

let
  perlDeps = [
    authenpam
    pve-common
  ];

  perlEnv = perl5.withPackages (_: perlDeps);
in

perl5.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-access-control";
    version = "9.0.5";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "df0a60e74d8040f3a8f066c840a76c4b5b8aff9e";
      hash = "sha256-oOXmlHts7KUjzqGLAnqhCvQ0NfX7wRBF+t55UeVjyLI=";
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
      "PERLDIR=/${perl5.libPrefix}/${perl5.version}"
    ];

    passthru.updateScript = pve-update-script {
      extraArgs = [
        "--deb-name"
        "libpve-access-control"
      ];
    };

    meta = with lib; {
      description = "Proxmox VE Access control framework";
      homepage = "https://git.proxmox.com/?p=pve-access-control.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
