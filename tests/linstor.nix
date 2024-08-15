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
    pve1.start()
    pve2.start()
    pve1.wait_for_unit("pveproxy.service")
    pve1.wait_for_unit("linstor-controller.service")
    assert "running" in pve1.succeed("pveproxy status")
    assert "Proxmox" in pve1.succeed("curl -k https://localhost:8006")
    pve1.succeed("pvecm create mycluster")
    pve1.wait_for_unit("corosync.service")
    pve2.wait_for_unit("multi-user.target")
  '';
}
