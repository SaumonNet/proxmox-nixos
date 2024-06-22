{

  name = "proxmox-ve";

  nodes.mypve = {
    services.proxmox-ve = {
      enable = true;
      localIP = "192.168.1.1";
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("pveproxy.service")
    assert "running" in machine.succeed("pveproxy status")
  '';
}
