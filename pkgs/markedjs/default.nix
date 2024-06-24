{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "markedjs";
  version = "13.0.1";

  src = fetchFromGitHub {
    owner = "markedjs";
    repo = "marked";
    rev = "v${version}";
    hash = "sha256-njs0PTzJ8JIUVN2DCpvCZlguTeeBMpDZg4X2gZ2uR9s=";
  };

  npmDepsHash = "sha256-u3Y3Z8gWMXjwuHW/Vq5tsnoox34FKpcuCXJkZ5tA80w=";

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
