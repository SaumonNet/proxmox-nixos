{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "markedjs";
  version = "16.1.2";

  src = fetchFromGitHub {
    owner = "markedjs";
    repo = "marked";
    rev = "v${version}";
    hash = "sha256-RmeLGIZSgMRfwBKbWblGUA/k0w4I3CYARIt2qW6m+Qw=";
  };

  npmDepsHash = "sha256-7lO4bZ2ajCg0n3e3+2IYjYYAVC5ToSFuJ79U4/LvJzM=";

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
