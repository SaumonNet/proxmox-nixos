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
  version = "2.0.2";

  src = fetchgit {
    url = "git://git.proxmox.com/git/pve-xtermjs.git";
    rev = "c69379f49db91429eb01ea56b47f2a2832fec8e7";
    hash = "sha256-U4sT3fXsq/Tza00ycnPaEaQrYlBtscsv5rRCJZPM3Uw=";
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
