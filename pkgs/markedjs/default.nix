{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "markedjs";
  version = "15.0.3";

  src = fetchFromGitHub {
    owner = "markedjs";
    repo = "marked";
    rev = "v${version}";
    hash = "sha256-OiG4LZefvJymRASnCb0GABjRjOc6qaQCDLdxaacOY04=";
  };

  npmDepsHash = "sha256-64xxhK9uNEfXliRkiCsZhKmN/I/whitvNcL2YR2zdew=";

  passthru.updateScript = nix-update-script { extraArgs = [ "--flake" ]; };

  meta = with lib; {
    description = "A markdown parser and compiler. Built for speed";
    homepage = "https://marked.js.org/";
    license = licenses.mit;
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
