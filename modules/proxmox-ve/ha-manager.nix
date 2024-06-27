{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.proxmox-ve.enable {
  systemd.services = {
    pve-ha-lrm = {
      description = "PVE Local HA Resource Manager Daemon";
      wantedBy = [ "multi-user.target" ];
      wants = [
        "pve-cluster.service"
        "watchdog-mux.service"
        "pvedaemon.service"
        "pve-ha-crm.service"
        "lxc.service"
        "pve-storage.target"
      ];
      after = [
        "corosync.service"
        "lxc.service"
        "pve-cluster.service"
        "pve-ha-crm.service"
        "pve-storage.target"
        "pvedaemon.service"
        "pveproxy.service"
        "sshd.service"
        "syslog.service"
        "watchdog-mux.service"
      ];
      serviceConfig = {
        ExecStart = "${pkgs.pve-ha-manager}/bin/pve-ha-lrm start";
        ExecStop = "${pkgs.pve-ha-manager}/bin/pve-ha-lrm stop";
        PIDFile = "/run/pve-ha-lrm.pid";
        #TimeoutStopSec = "infinity";
        KillMode = "process";
        Type = "forking";
      };
    };

    pve-ha-crm = {
      description = "PVE Cluster HA Resource Manager Daemon";
      wants = [
        "pve-cluster.service"
        "watchdog-mux.service"
        "pvedaemon.service"
      ];
      after = [
        "pve-cluster.service"
        "corosync.service"
        "pvedaemon.service"
        "watchdog-mux.service"
        "syslog.service"
      ];
      serviceConfig = {
        ExecStart = "${pkgs.pve-ha-manager}/bin/pve-ha-crm start";
        ExecStop = "${pkgs.pve-ha-manager}/bin/pve-ha-crm stop";
        PIDFile = "/run/pve-ha-crm.pid";
        TimeoutStopSec = 65;
        Type = "forking";
      };
    };
  };
}
