{

  name = "pve-cluster";

  nodes = {
    pve1 = {
      services.proxmox-ve.enable = true;
    };
    pve2 = {
      services.proxmox-ve.enable = true;
    };
  };

  testScript = ''
    pve1.start()
    pve2.start()
    pve1.wait_for_unit("pveproxy.service")
    assert "running" in pve1.succeed("pveproxy status")
    assert "Proxmox" in pve1.succeed("curl -k https://localhost:8006")
    pve1.succeed("pvecm create mycluster")
    pve1.wait_for_unit("corosync.service")
    pve2.wait_for_unit("multi-user.target")
    pve2.succeed("pvecm join mycluster")
  '';
}
