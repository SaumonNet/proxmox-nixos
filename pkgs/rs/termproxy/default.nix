{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "termproxy";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "proxmox";
    repo = "pve-xtermjs";
    rev = "9e209b042bad4f3cf524654c1484ec8061a9edfb";
    hash = "sha256-Ifnv0sYC9nNHuHPpXwTn+2vKSFHpnFn1Gwc59s5kzOE=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };


  postPatch = ''
    rm -rf .cargo
    cd termproxy
    rm Cargo.toml
    ln -s ${./Cargo.toml} Cargo.toml
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  postInstall = ''
    mv $out/bin/proxmox-termproxy $out/bin/termproxy
  '';

  meta = with lib; {
    maintainers = [ ];
  };
}
