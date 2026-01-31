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
  version = "2.0.3";

  src = fetchgit {
    url = "git://git.proxmox.com/git/pve-xtermjs.git";
    rev = "1c92330cccb21fb65abcff6e35848b712592dccb";
    hash = "sha256-it1zIt+vVSgGw8mII+l7cq+vyV7tnuqNkBbgbBw7szw=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  prePatch = ''
    rm .cargo/config.toml
    cd termproxy
    cat ${registry}/cargo-patches.toml >> Cargo.toml
    cp ${./Cargo.lock} Cargo.lock
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
