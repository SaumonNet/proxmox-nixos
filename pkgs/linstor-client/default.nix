{
  lib,
  python310,
  fetchFromGitHub,
  linstor-api-py,
  nix-update-script,
}:

python310.pkgs.buildPythonApplication rec {
  pname = "linstor-client";
  version = "1.23.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "LINBIT";
    repo = "linstor-client";
    rev = "v${version}";
    hash = "sha256-DxYtqJr8ZOlwQdX4s4UF1BnzQsJQaYQOYOupbN3kD5k=";
  };

  nativeBuildInputs = [
    python310.pkgs.setuptools
    python310.pkgs.wheel
  ];

  propagatedBuildInputs = [ linstor-api-py ];

  pythonImportsCheck = [ "linstor_client" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--flake" ]; };

  meta = with lib; {
    description = "Python client for LINSTOR";
    homepage = "https://github.com/LINBIT/linstor-client";
    changelog = "https://github.com/LINBIT/linstor-client/blob/${src.rev}/CHANGELOG.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    mainProgram = "linstor";
  };
}
