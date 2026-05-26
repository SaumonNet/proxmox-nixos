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
    version = "9.1.1";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "5ccd07d9302562b73374d331b63d25b04b86766c";
      hash = "sha256-r3k/eReQm4zqdLV3V00l9hrhz0xj0Qi4OOxrHj/f0vI=";
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
