{ pkgs, ... }:

{
  systemd.services = {
    pve-firewall = {
      description = "Proxmox VE firewall";
      unitConfig = {
        Wants = [ "pve-cluster.service" "pvefw-logger.service" ];
        After = [ "pvefw-logger.service" "pve-cluster.service" "network.target" "systemd-modules-load.service" ];
        DefaultDependencies = "no";
        Before = [ "shutdown.target" ];
        Conflicts = [ "shutdown.target" ];
      };
      serviceConfig = {
        ExecStart = "${pkgs.pve-firewall}/bin/pve-firewall start";
        ExecStop = "${pkgs.pve-firewall}/bin/pve-firewall stop";
        ExecReload = "${pkgs.pve-firewall}/bin/pve-firewall restart";
        PIDFile = "/run/pve-firewall.pid";
        Type = "forking";
      };
    };

    pvefw-logger = {
      description = "Proxmox VE firewall logger";
      unitConfig = {
        DefaultDependencies = "no";
        Before = [ "shutdown.target" ];
        After = [ "local-fs.target" ];
        Conflicts = [ "shutdown.target" ];
      };
      serviceConfig = {
        ExecStart = "${pkgs.pve-firewall}/bin/pvefw-logger";
        PIDFile = "/run/pvefw-logger.pid";
        TimeoutStopSec = 5;
        Type = "forking";
      };
    };
  };
}


