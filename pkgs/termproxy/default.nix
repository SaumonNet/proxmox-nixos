{
  lib,
  fetchgit,
  rustPlatform,
  mkRegistry,
  pve-update-script,
}:

let
  sources = import ./sources.nix;
  registry = mkRegistry sources;
in

rustPlatform.buildRustPackage rec {
  pname = "termproxy";
  version = "2.1.0";

  src = fetchgit {
    url = "git://git.proxmox.com/git/pve-xtermjs.git";
    rev = "e1ab45d3d60239e4ee3ba5058258ccdc34d6e43b";
    hash = "sha256-A4MYfT+2Sf4HvKthgVmX0CeqTc0BMggm/BrT6hG+7II=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  prePatch = ''
    rm .cargo/config.toml
    cd termproxy
    cat ${registry}/cargo-patches.toml >> Cargo.toml
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  buildInputs = [ registry ];

  postInstall = ''
    mv $out/bin/{proxmox-,}termproxy
  '';

  passthru = {
    inherit registry;

    updateScript = pve-update-script {
      extraArgs = [
        "--deb-name"
        "proxmox-termproxy"
        "--use-git-log"
      ];
    };
  };

  meta = with lib; {
    description = "xterm.js helper utility";
    homepage = "https://git.proxmox.com/?p=pve-xtermjs.git";
    license = with licenses; [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
