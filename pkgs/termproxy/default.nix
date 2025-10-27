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
  version = "1.1.0";

  src = fetchgit {
    url = "git://git.proxmox.com/git/pve-xtermjs.git";
    rev = "9bf8b31e8daac4fa9f464bff9e864a7b10179609";
    hash = "sha256-OmL57wuLQGqfm1089hy2q40gHyti2PHzkizfWYRXQaU=";
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
