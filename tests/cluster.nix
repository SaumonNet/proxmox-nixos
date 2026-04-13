{ lib, ... }:

let
  cluster = import ./cluster-common.nix { inherit lib; };
in
{
  name = "pve-cluster";

  inherit (cluster) nodes;

  testScript = ''
    ${cluster.clusterSetupScript}
  '';
}
