{

  name = "pbs-basic";

  nodes.mypve = {
    services.proxmox-backup-server = {
      enable = true;
      localIP = "192.168.1.1";
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("proxmox-backup.service")
  '';
}
