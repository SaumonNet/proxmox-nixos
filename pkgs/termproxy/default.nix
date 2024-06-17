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
    rev = "e2e62fc67368ad25a35c6d009f9d85ac5ef97233";
    hash = "sha256-Inx3LnAelDwvRoLHqMG91lUuQUI/CvNVIZ/EfmeIFUM=";
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
    mv $out/bin/{proxmox-,}termproxy
  '';

  passthru.updateScript = [
    ../update.sh
    pname
    src.url
    "--prefix"
    "termproxy: bump version to"
    "--root"
    pname
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
  };
}
