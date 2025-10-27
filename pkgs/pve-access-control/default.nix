{
  lib,
  stdenv,
  fetchgit,
  perl538,
  pve-common,
  authenpam,
  pve-update-script,
}:

let
  perlDeps = [
    authenpam
    pve-common
  ];

  perlEnv = perl538.withPackages (_: perlDeps);
in

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-access-control";
    version = "8.2.2";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "25dd3756f90afbf65799da4708b3df9c2bf7e9f6";
      hash = "sha256-gmTlDvOTPeFNB2W0H3xHZBWsRFY6XeIb0r/1qNzsphA=";
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
      "PERLDIR=/${perl538.libPrefix}/${perl538.version}"
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
