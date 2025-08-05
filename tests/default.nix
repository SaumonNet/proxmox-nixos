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
  test-pve-ceph = runTest ./vm.nix;
  test-pve-cluster = runTest ./cluster.nix;
  test-pve-container = runTest ./container.nix;
  # Disable this test until drdb gets unbroken in 24.11
  test-pve-linstor = runTest ./linstor.nix;
  test-pve-vm = runTest ./vm.nix;
}
