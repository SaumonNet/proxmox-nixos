let
  pkgs = import
    (
      let lock = builtins.fromJSON (builtins.readFile ./flake.lock); in
      fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/${lock.nodes.nixpkgs.locked.rev}.tar.gz";
        sha256 = lock.nodes.nixpkgs.locked.narHash;
      }
    )
    { };
in
import ./pkgs { pkgs = pkgs; }
