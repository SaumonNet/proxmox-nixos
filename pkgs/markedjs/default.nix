{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "markedjs";
  version = "14.0.0";

  src = fetchFromGitHub {
    owner = "markedjs";
    repo = "marked";
    rev = "v${version}";
    hash = "sha256-ljRFX0L3fzVIH0v+ZfwET10UOROBeWC1W/RkF5n7fxQ=";
  };

  npmDepsHash = "sha256-13SfTxNiWoCfonwgvpOFSShfEZ+/wf1CniCm7VW3Q1A=";

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
