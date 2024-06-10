{ lib
, stdenv
, fetchgit
, callPackage
, perl
, pve-common ? callPackage ./common.nix { }
}:

let
  perlDeps = with perl.pkgs; with callPackage ../perl-packages.nix { }; [
    AuthenPAM
    pve-common
  ];

  perlEnv = perl.withPackages (_: perlDeps);
in

perl.pkgs.toPerlModule (stdenv.mkDerivation rec {
  pname = "pve-access-control";
  version = "8.0.3";

  src = fetchgit {
    url = "https://git.proxmox.com/git/${pname}.git";
    rev = "8a856968f778fdac953bec36d62bd57f3efc5ae6";
    hash = "sha256-FErbHoGcKQ7yQlRliD2I5KpCzPXSBDjOnL32lsqE9Ao=";
  };

  sourceRoot = "source/src";

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
    maintainers = with maintainers; [ camillemndn julienmalka ];
    platforms = platforms.linux;
  };
})
