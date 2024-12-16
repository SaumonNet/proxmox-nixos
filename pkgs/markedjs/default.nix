{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "markedjs";
  version = "15.0.4";

  src = fetchFromGitHub {
    owner = "markedjs";
    repo = "marked";
    rev = "v${version}";
    hash = "sha256-opYsbQLliSEz2nYGHuqM/QeYcqEh7LQtqLzc1ppByHI=";
  };

  npmDepsHash = "sha256-e1AnslmDu831L3lD2eS+mGskKJ2s15fCwQkgLtFzP+o=";

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
