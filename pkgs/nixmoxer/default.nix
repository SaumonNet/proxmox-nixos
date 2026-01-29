{
  lib,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "nixmoxer";
  version = "1.0.0";
  pyproject = true;

  src = ./.;

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    proxmoxer
    click
    requests-toolbelt
  ];

  meta = with lib; {
    description = "Declarative Proxmox VM bootstrap";
    homepage = "https://github.com/SaumonNet/proxmox-nixos";
    license = [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    mainProgram = "nixmoxer";
    platforms = platforms.all;
  };
}
