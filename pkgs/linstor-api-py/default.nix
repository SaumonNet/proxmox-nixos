{
  lib,
  python310,
  fetchFromGitHub,
}:

python310.pkgs.buildPythonPackage rec {
  pname = "linstor-api-py";
  version = "1.23.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "LINBIT";
    repo = "linstor-api-py";
    rev = "v${version}";
    hash = "sha256-+nv1Lp14X7a5BVHYGWFEESO95MsTa6NLPJSRJvIJc3w=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    python310.pkgs.setuptools
    python310.pkgs.wheel
    python310.pkgs.distutils
  ];

  pythonImportsCheck = [ "linstor" ];

  meta = with lib; {
    description = "LINSTOR Python API";
    homepage = "https://github.com/LINBIT/linstor-api-py";
    changelog = "https://github.com/LINBIT/linstor-api-py/blob/${src.rev}/CHANGELOG.md";
    license = [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
  };
}
