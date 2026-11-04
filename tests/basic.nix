{
  name = "pve-basic";

  nodes.mypve = {
    services.proxmox-ve = {
      enable = true;
      ipAddress = "192.168.1.1";
    };
  };

  testScript = ''
    mypve.start()
    mypve.wait_for_unit("pveproxy.service")
    assert "running" in mypve.succeed("pveproxy status")
    assert "Proxmox" in mypve.succeed("curl -k https://localhost:8006")
    mypve.succeed("pvecm create mycluster")
    mypve.wait_for_unit("corosync.service")
  '';
}
