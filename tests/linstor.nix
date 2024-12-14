{
  name = "pve-linstor";

  nodes = {
    pve1 = {
      services = {
        proxmox-ve = {
          enable = true;
          ipAddress = "192.168.0.1";
          linstor.enable = true;
        };
        lvm.enable = true;
        lvm.dmeventd.enable = true;
      };
      virtualisation = {
        emptyDiskImages = [ 10000 ];
        memorySize = 2048;
      };
      lvm.enable = true;
      lvm.dmeventd.enable = true;
    };
    virtualisation = {
      emptyDiskImages = [ 10000 ];
      memorySize = 2048;
    };
  };

  testScript = ''
    start_all()

    pve1.wait_for_unit("pveproxy.service")
    assert "running" in pve1.succeed("pveproxy status")
    assert "Proxmox" in pve1.succeed("curl -k https://localhost:8006")

    pve1.wait_for_unit("multi-user.target")

    pve1.wait_for_unit("linstor-satellite.service")
    pve1.wait_for_unit("linstor-controller.service")
    pve1.succeed("pvcreate /dev/vdb >&2")
    pve1.succeed("vgcreate linstor_vg /dev/vdb >&2")
    pve1.succeed("lvcreate -l 80%FREE -T linstor_vg/thinpool >&2")

    pve1.succeed("linstor node list >&2")
    pve1.succeed("linstor node create pve1 127.0.0.1 >&2")
    pve1.succeed("linstor node info >&2")
    pve1.succeed("linstor storage-pool create lvmthin pve1 pve-storage linstor_vg/thinpool >&2")
    pve1.succeed("linstor resource-group create test --storage-pool pve-storage --place-count 1 >&2")
    pve1.succeed("linstor volume-group create test")
    pve1.succeed("linstor resource-group spawn-resources test test_res 1G >&2")
    pve1.succeed("linstor resource list >&2")

  '';
}
