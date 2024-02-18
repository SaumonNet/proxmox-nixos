{ lib
, rustPlatform
, fetchgit
}:

rustPlatform.buildRustPackage rec {
  pname = "proxmox";
  version = "unstable";

  src = fetchgit {
    url = "https://git.proxmox.com/git/proxmox.git";
    rev = "3ac6f2d9c0b3e1aa6f980a389f4e4e68f53a2524";
    hash = "sha256-Jfsgysij+Bmu47O5gC/CzT3FRj5IIMVnSoOcCCl0wvc=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  meta = with lib; {
    description = "";
    homepage = "https://git.proxmox.com/git/proxmox.git";
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "proxmox";
  };
}
