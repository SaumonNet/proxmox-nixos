{
  lib,
  stdenv,
  fetchgit,
  perl540,
  pve-common,
  authenpam,
  pve-update-script,
}:

let
  perlDeps = [
    authenpam
    pve-common
  ];

  perlEnv = perl540.withPackages (_: perlDeps);
in

perl540.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-access-control";
    version = "9.0.4";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "3e9da0c8e3845bba9d2d61f537a4d3278eb9f477";
      hash = "sha256-+puV+Pt1DE9b1nPmbH5OoIH/fEhBUgbb4XlKNCZVQuI=";
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
      "PERLDIR=/${perl540.libPrefix}/${perl540.version}"
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
