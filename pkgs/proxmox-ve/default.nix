{
  lib,
  buildEnv,
  pve-access-control,
  pve-cluster,
  pve-container,
  pve-firewall,
  pve-ha-manager,
  pve-manager,
  pve-qemu-server,
  pve-storage,
  termproxy,
  vncterm,
  wget,
}:

buildEnv rec {
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
    termproxy
    vncterm
    wget
  ];

  meta = with lib; {
    description = "A complete, open-source server management platform for enterprise virtualization";
    homepage = "https://proxmox.com/proxmox-virtual-environment/";
    license = concatMap (pkg: toList pkg.meta.license) paths;
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
