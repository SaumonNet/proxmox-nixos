{ lib, ... }:

let
  cluster = import ./cluster-common.nix { inherit lib; };
in
{
  name = "pve-cluster-conntrack";

  inherit (cluster) nodes;

  testScript = ''
    import re

    ${cluster.clusterSetupScript}
    ${cluster.vmSetupScript}
    ${cluster.conntrackSetupScript}

    migrate_output = pve1.succeed(
      "qm migrate ${toString cluster.vmid} pve2 --online --with-local-disks --targetstorage local --with-conntrack-state 1"
    )
    assert re.search(r"migrated [1-9][0-9]* conntrack state entr", migrate_output), migrate_output

    ${cluster.clusterValidationScript}
    ${cluster.dbusVmstateValidationScript}
    ${cluster.conntrackValidationScript}
  '';
}
