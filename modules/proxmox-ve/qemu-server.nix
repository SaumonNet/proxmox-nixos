{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.proxmox-ve.enable {
  # Mirror upstream qemu-server's debian/tmpfiles. /run/qemu-server/efidisk
  # is required by `qm start` for OVMF VMs without an explicit efidisk0
  # since qemu-server 9.1.10 (commit c7e62814) moved the temporary EFI disk
  # to /run.
  systemd.tmpfiles.rules = [
    "d /run/qemu-server         0750 root www-data -"
    "d /run/qemu-server/efidisk 0750 root www-data -"
  ];

  systemd.services.qmeventd = {
    description = "PVE Qemu Event Daemon";
    unitConfig.RequiresMountsFor = [ "/var/run" ];
    wantedBy = [ "multi-user.target" ];
    before = [
      "pve-ha-lrm.service"
      "pve-guests.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.pve-ha-manager}/bin/qmeventd /var/run/qmeventd.sock";
      Type = "forking";
    };
  };
}
