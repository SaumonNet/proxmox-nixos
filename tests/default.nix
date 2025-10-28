{ pkgs, extraBaseModules }:

let
  runTest =
    module:
    pkgs.testers.runNixOSTest {
      imports = [ module ];
      globalTimeout = 5 * 60;
      extraBaseModules = {
        imports = builtins.attrValues extraBaseModules;
      };
    };
in
{
  test-pve-basic = runTest ./basic.nix;
  # test-pve-ceph = runTest ./ceph.nix;
  test-pve-cluster = runTest ./cluster.nix;
  test-pve-linstor = runTest ./linstor.nix;
  test-pve-vm = runTest ./vm.nix;
}
