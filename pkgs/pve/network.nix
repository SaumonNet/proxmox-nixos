{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "pve-network";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "proxmox";
    repo = "pve-network";
    rev = "fd1ae5044edc0f6ab2793aebddd90fcf6dd549ad";
    hash = "sha256-6ZpeqpHIbEoIRjDgZZv3Zyn+gGqoWrNxvU3wzGqiKPE=";
  };

  meta = with lib; {
    description = "";
    homepage = "https://github.com/proxmox/pve-network";
    license = with licenses; [ ];
    maintainers = with maintainers; [ ];
  };
}
