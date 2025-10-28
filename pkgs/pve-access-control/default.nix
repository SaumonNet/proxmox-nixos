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
    version = "9.0.3";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "2c67c26f61138e9a97c5aab450d05a865eea6413";
      hash = "sha256-7ZZQAKgqIpzAqU+hbgiZB6uEkTQkTrovpUUmUKKlcRY=";
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
