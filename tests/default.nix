{ pkgs, extraBaseModules }:

let
  testLib = import ./lib.nix { inherit pkgs; };
  runTest =
    modulePath:
    let
      module = import modulePath;
      resolvedModule = if builtins.isFunction module then module testLib else module;
    in
    pkgs.testers.runNixOSTest {
      imports = [ resolvedModule ];
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
  test-pve-cluster-conntrack = runTest ./cluster-conntrack.nix;
  test-pve-iso-upload = runTest ./iso-upload.nix;
  test-pve-linstor = runTest ./linstor.nix;
  test-pve-reboot = runTest ./reboot.nix;
  test-pve-vm = runTest ./vm.nix;
}
