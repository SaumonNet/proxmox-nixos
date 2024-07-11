{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.proxmox-ve.enable {
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
