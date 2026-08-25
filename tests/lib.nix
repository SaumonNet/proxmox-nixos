{ pkgs }:

{
  minimalIso = pkgs.fetchurl {
    url = "https://releases.nixos.org/nixos/24.05/nixos-24.05.7139.bcba2fbf6963/nixos-minimal-24.05.7139.bcba2fbf6963-x86_64-linux.iso";
    hash = "sha256-plre/mIHdIgU4xWU+9xErP+L4i460ZbcKq8iy2n4HT8=";
  };
}
