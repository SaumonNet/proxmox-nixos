{
  lib,
  python311,
  fetchFromGitHub,
  linstor-api-py,
  nix-update-script,
}:

python311.pkgs.buildPythonApplication rec {
  pname = "linstor-client";
  version = "1.27.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "LINBIT";
    repo = "linstor-client";
    rev = "v${version}";
    hash = "sha256-k/b/5fwwP+3wsnlFvDmACdmEokFTQjoTLjzO8zojhp8=";
  };

  # Upstream uses distro package names in install_requires (e.g. python3-setuptools)
  # instead of PyPI names (e.g. setuptools), since they distribute via Debian/RPM.
  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail '"python3-setuptools"' '"setuptools",'
  '';

  nativeBuildInputs = [
    python311.pkgs.setuptools
    python311.pkgs.wheel
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
