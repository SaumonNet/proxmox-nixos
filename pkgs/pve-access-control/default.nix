{
  lib,
  stdenv,
  fetchgit,
  perl538,
  pve-common,
  authenpam,
}:

let
  perlDeps = with perl538.pkgs; [
    authenpam
    pve-common
  ];

  perlEnv = perl538.withPackages (_: perlDeps);
in

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-access-control";
    version = "9.0.2";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "4adb2a3a1187e61617cc5ec999f6e953f69a25e7";
      hash = "sha256-ZHFu4bLjRk3YXm58FCY+L4vF9N0wl3buhZzh4wHfeb0=";
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

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
    ];

    meta = with lib; {
      description = "Proxmox VE Access control framework";
      homepage = "git://git.proxmox.com/?p=pve-access-control.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
