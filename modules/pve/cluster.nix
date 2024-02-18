{ pkgs, ... }:

{
  systemd.services = {
    pve-cluster = {
      description = "The Proxmox VE cluster filesystem";
      wants = [
        "corosync.service"
        #"rrdcached.service"
        #"shutdown.target"
      ];
      after = [
        "network.target"
        "sys-fs-fuse-connections.mount"
        "time-sync.target"
        #"rrdcached.service"
      ];
      before = [ "corosync.service" "cron.service" ];
      #unitConfig = {
      #  DefaultDependencies = false;
      #  Conflicts = [ "shutdown.target" ];
      #};
      serviceConfig = {
        ExecStart = "${pkgs.pve-cluster}/bin/pmxcfs";
        KillMode = "mixed";
        Restart = "on-failure";
        TimeoutStopSec = 10;
        Type = "forking";
        PIDFile = "/run/pve-cluster.pid";
      };
    };
  };
}

