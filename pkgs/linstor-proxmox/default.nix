{
  lib,
  stdenv,
  fetchFromGitHub,
  perl540,
  nix-update-script,
}:

let
  perlDeps = with perl540.pkgs; [
    JSONXS
    RESTClient
    TypesSerialiser
  ];

  perlEnv = perl540.withPackages (_: perlDeps);
in

perl540.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "linstor-proxmox";
    version = "8.1.3";

    src = fetchFromGitHub {
      owner = "LINBIT";
      repo = "linstor-proxmox";
      rev = "v${version}";
      hash = "sha256-edD77DlsYozs2sgLykZkFOYTLnkbG9dGgt/Q/94Jwnw=";
    };

    makeFlags = [
      "DESTDIR=$(out)"
      "PERLDIR=/${perl540.libPrefix}/${perl540.version}"
    ];

    buildInputs = [ perlEnv ];
    propagatedBuildInputs = perlDeps;

    passthru.updateScript = nix-update-script { extraArgs = [ "--flake" ]; };

    meta = with lib; {
      description = "Integration pluging bridging LINSTOR to Proxmox VE";
      homepage = "https://github.com/LINBIT/linstor-proxmox";
      changelog = "https://github.com/LINBIT/linstor-proxmox/blob/${src.rev}/CHANGELOG.md";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
