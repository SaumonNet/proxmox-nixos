let
  common = import ./ceph-common.nix;
in
{
  name = "pve-ceph";
  imports = [ common.module ];

  testScript = common.setupScript + ''
    with subtest("Read a replicated object from another node"):
        # Start this small pool at the Ceph autoscaler's default minimum.
        pve1.succeed("pveceph pool create testpool --size 3 --pg_num 32")
        wait_for_health()
        pve1.succeed("printf 'Ceph cluster test' | rados -p testpool put probe -")
        assert pve2.succeed("rados -p testpool get probe -") == "Ceph cluster test"

    with subtest("Recover both OSDs and read the updated object after reboot"):
        pve3.shutdown()
        wait_for_osds(up=2)
        assert pve2.succeed("rados -p testpool get probe -") == "Ceph cluster test"
        pve2.succeed("printf 'Written during outage' | rados -p testpool put probe -")

        pve3.start()
        wait_for_osds()
        wait_for_health()
        assert pve3.succeed("rados -p testpool get probe -") == "Written during outage"
  '';
}
