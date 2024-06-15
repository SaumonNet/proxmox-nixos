{
  lib,
  fetchgit,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "termproxy";
  version = "1.0.1";

  src = fetchgit {
    url = "https://git.proxmox.com/git/pve-xtermjs.git";
    rev = "9e209b042bad4f3cf524654c1484ec8061a9edfb";
    hash = "sha256-Ifnv0sYC9nNHuHPpXwTn+2vKSFHpnFn1Gwc59s5kzOE=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  prePatch = ''
    rm .cargo/config
    cd termproxy
    cp ${./Cargo.toml} Cargo.toml
    cp ${./Cargo.lock} Cargo.lock
  '';

  postInstall = ''
    mkdir $out/share
    mv $out/bin/proxmox-termproxy $out/share/termproxy
  '';

  passthru.updateScript = [
    ../update.sh
    pname
    src.url
    "termproxy: bump version to"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
  };
}
