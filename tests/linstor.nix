{

  name = "pve-linstor";

  nodes = {
    pve1 = {
      services.proxmox-ve = {
        enable = true;
        linstor.enable = true;
      };
      virtualisation.memorySize = 2048;
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

    pve1.wait_for_unit("linstor-controller.service")
    pve2.wait_for_unit("multi-user.target")

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

    pve1.succeed("linstor node create pve1 192.168.0.1")
  '';
}
