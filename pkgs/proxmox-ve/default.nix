{
  lib,
  buildEnv,
  linstor-client,
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
  enableLinstor ? false,
}:

buildEnv rec {
  name = "proxmox-ve-${pve-manager.version}";

  paths = [
    pve-access-control
    pve-cluster
    pve-container
    pve-firewall
    (pve-ha-manager.override { inherit enableLinstor; })
    (pve-manager.override { inherit enableLinstor; })
    pve-qemu-server
    (pve-storage.override { inherit enableLinstor; })
    termproxy
    vncterm
    wget
  ] ++ lib.optionals enableLinstor [ linstor-client ];

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
