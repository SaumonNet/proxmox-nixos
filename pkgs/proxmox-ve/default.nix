{ lib
, buildEnv
, pve-access-control
, pve-cluster
, pve-container
, pve-firewall
, pve-ha-manager
, pve-manager
, pve-qemu-server
, pve-storage
}:

buildEnv {
  name = "proxmox-ve-${pve-manager.version}";

  paths = [
    pve-access-control
    pve-cluster
    pve-container
    pve-firewall
    pve-ha-manager
    pve-manager
    pve-qemu-server
    pve-storage
  ];

  meta = with lib; {
    description = "Read-Only mirror of the Proxmox VE Managaer API and Web UI repository";
    homepage = "https://github.com/proxmox/pve-manager";
    license = with licenses; [ ];
    maintainers = with maintainers; [ camillemndn julienmalka ];
    platforms = platforms.linux;
  };
}
