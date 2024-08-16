{

  name = "pve-linstor";

  nodes = {
    pve1 = {
      services = {
        proxmox-ve = {
          enable = true;
          linstor.enable = true;
        };
        lvm.enable = true;
        lvm.dmeventd.enable = true;
      };
      virtualisation = {
        emptyDiskImages = [ 4096 ];
        memorySize = 2048;
      };
    };
    pve2 = {
      services.proxmox-ve = {
        enable = true;
        linstor.enable = true;
      };
      virtualisation.memorySize = 2048;
    };
  };

  testScript = ''
    start_all()

    pve1.wait_for_unit("pveproxy.service")
    assert "running" in pve1.succeed("pveproxy status")
    assert "Proxmox" in pve1.succeed("curl -k https://localhost:8006")

    pve1.wait_for_unit("multi-user.target")
    pve2.wait_for_unit("multi-user.target")

    pve1.succeed("linstor node create pve1 192.168.0.1")
    pve1.succeed("vgcreate linstor_vg /dev/vdb")
    pve1.succeed("lvcreate -l 80%FREE -T linstor_vg/thinpool")
    pve1.succeed("linstor storage-pool create lvmthin pve1 pve-storage linstor_vg/thinpool")
    pve1.succeed("linstor resource-group create pve-rg --storage-pool=pve-storage --place-count=1")
    pve1.succeed("linstor volume-group create pve-rg")

    storageCfg = """
    drbd: linstor_storage
        content images, rootdir
        controller 192.168.0.1
        resourcegroup pve-rg
    """
    pve1.succeed(f"echo \"{storageCfg}\" >> /etc/pve/storage.cfg")
    pve1.succeed("cat /etc/pve/storage.cfg")
    assert "9.2" in pve1.succeed("modinfo drbd")
    assert "drbd" in pve1.succeed("cat /proc/modules")

    pve1.succeed("systemctl restart pve-cluster pvedaemon pvestatd pveproxy")

    pve1.succeed("linstor node create pve1 192.168.0.1")
  '';
}
