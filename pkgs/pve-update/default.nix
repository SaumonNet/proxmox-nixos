{
  lib,
  python3Packages,
  cargo,
  common-updater-scripts,
  dpkg,
  git,
  nix-prefetch-git,
}:

python3Packages.buildPythonApplication {
  pname = "pve-update";
  version = "1.0.0";
  pyproject = true;

  src = ./.;

  propagatedBuildInputs = [
    cargo
    common-updater-scripts
    dpkg
    git
    nix-prefetch-git
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    aiohttp
    beautifulsoup4
    python-debian
  ];

  meta = with lib; {
    description = "Updater for Proxmox-NixOS derivations";
    homepage = "https://github.com/SaumonNet/proxmox-nixos";
    license = [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    mainProgram = "pve-update";
    platforms = platforms.all;
  };
}
