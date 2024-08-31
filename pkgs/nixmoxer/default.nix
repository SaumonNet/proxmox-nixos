{ python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "nixmoxer";
  version = "1.0.0";
  pyproject = true;

  src = ./.;

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    proxmoxer
    click
    requests_toolbelt
  ];

  postInstall = ''
    mkdir -p $out/share
    cp iso.nix $out/share
    cp eval-non-flake.nix $out/share
  '';
}
