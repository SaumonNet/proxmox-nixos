{ lib, ... }:

let
  common = import ./ceph-common.nix;
in
{
  name = "pve-ceph-rbd";
  imports = [ common.module ];
  globalTimeout = lib.mkForce (20 * 60);

  nodes.pve1 = { pkgs, ... }: {
    environment.etc."rbd-guest.qcow2".source = import ./ceph-rbd-guest.nix { inherit pkgs; };
    virtualisation.memorySize = lib.mkForce 3072;
  };
  nodes.pve2.virtualisation.memorySize = lib.mkForce 3072;

  testScript = common.setupScript + ''
    import json
    import shlex

    def guest_exec(host, command):
        result = json.loads(host.succeed(
            f"qm guest exec 100 --timeout 120 -- /bin/sh -c {shlex.quote(command)}"
        ))
        assert result["exitcode"] == 0, result
        return result.get("out-data", "")

    with subtest("Create and boot a guest on replicated RBD storage"):
        pve1.succeed("pveceph pool create vmpool --size 3 --pg_num 32 --add_storages 1")
        wait_for_health()
        pve1.succeed("qm create 100 --name rbd-guest --memory 1024 --cores 1 --kvm 0 --agent 1")
        pve1.succeed("qm importdisk 100 /etc/rbd-guest.qcow2 vmpool")
        pve1.succeed("qm set 100 --virtio0 vmpool:vm-100-disk-0 --boot order=virtio0")
        pve1.succeed("qm start 100")
        pve1.wait_until_succeeds("qm agent 100 ping", timeout=300)
        boot_id = guest_exec(pve1, "cat /proc/sys/kernel/random/boot_id")
        guest_exec(pve1, "printf 'before migration' > /root/marker && sync")
        assert guest_exec(pve1, "cat /root/marker") == "before migration"

    with subtest("Migrate the running guest and verify its disk"):
        pve1.succeed("qm migrate 100 pve2 --online")
        pve2.wait_until_succeeds("qm agent 100 ping", timeout=120)
        assert guest_exec(pve2, "cat /proc/sys/kernel/random/boot_id") == boot_id
        guest_exec(pve2, "sync && echo 3 > /proc/sys/vm/drop_caches")
        assert guest_exec(pve2, "cat /root/marker") == "before migration"
        guest_exec(pve2, "printf ' after migration' >> /root/marker && sync && echo 3 > /proc/sys/vm/drop_caches")
        assert guest_exec(pve2, "cat /root/marker") == "before migration after migration"
  '';
}
