let
  common = import ./ceph-common.nix;
in
{
  name = "pve-ceph";
  imports = [ common.module ];

  testScript = common.setupScript + ''
    import json

    def restart_osds(host, options=""):
        node = f"/nodes/{host.name}"
        # pvesh runs local tasks in the foreground and prints the UPID last.
        output = host.succeed(
            f"pvesh create {node}/ceph/restart-bulk --service-type osd {options} --output-format json"
        )
        upid = json.loads(output.splitlines()[-1])
        status = json.loads(host.succeed(f"pvesh get {node}/tasks/{upid}/status --output-format json"))
        assert status["status"] == "stopped", status
        return status["exitstatus"], output

    def osd_pid(host, osd_id):
        pid = int(host.succeed(f"systemctl show ceph-osd-{osd_id} --property MainPID --value"))
        assert pid > 0, f"osd.{osd_id} is down on {host.name}"
        return pid

    with subtest("Read a replicated object from another node"):
        # Start this small pool at the Ceph autoscaler's default minimum.
        pve1.succeed("pveceph pool create testpool --size 3 --pg_num 32")
        wait_for_health()
        pve1.succeed("printf 'Ceph cluster test' | rados -p testpool put probe -")
        assert pve2.succeed("rados -p testpool get probe -") == "Ceph cluster test"

    with subtest("Skip up-to-date OSDs in the restart plan"):
        result, plan = restart_osds(pve3, "--only-outdated 1 --dry-run 1")
        assert result == "OK", result
        assert "2 skipped, 0 remain" in plan, plan

    with subtest("Roll both OSDs on one node"):
        old_pids = {osd: osd_pid(pve3, osd) for osd in (2, 3)}
        result, _ = restart_osds(pve3)
        assert result == "OK", result
        for osd, pid in old_pids.items():
            assert osd_pid(pve3, osd) != pid, f"osd.{osd} did not restart"
        wait_for_osds()
        wait_for_health()
        assert pve2.succeed("rados -p testpool get probe -") == "Ceph cluster test"

    with subtest("Recover both OSDs and read the updated object after reboot"):
        pve3.shutdown()
        wait_for_osds(up=2)
        assert pve2.succeed("rados -p testpool get probe -") == "Ceph cluster test"
        pve2.succeed("printf 'Written during outage' | rados -p testpool put probe -")

        with subtest("Refuse a rolling restart on a degraded pool"):
            pid = osd_pid(pve2, 1)
            result, _ = restart_osds(pve2)
            assert "PG_DEGRADED" in result, result
            assert osd_pid(pve2, 1) == pid

        pve3.start()
        wait_for_osds()
        wait_for_health()
        assert pve3.succeed("rados -p testpool get probe -") == "Written during outage"
  '';
}
