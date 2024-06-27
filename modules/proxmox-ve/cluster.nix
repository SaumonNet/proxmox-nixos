{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.proxmox-ve.enable {
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
      before = [
        "corosync.service"
        "cron.service"
      ];
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

    corosync = {
      description = "Corosync Cluster Engine";
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      unitConfig = {
        ConditionKernelCommandLine = "!nocluster";
        ConditionPathExists = "/etc/corosync/corosync.conf";
      };
      serviceConfig = {
        ExecStart = "${pkgs.corosync}/bin/corosync -f $COROSYNC_OPTIONS";
        ExecStop = "${pkgs.corosync}/bin/corosync-cfgtool -H --force";
        Type = "notify";
        StateDirectory = "corosync";

        # In typical systemd deployments, both standard outputs are forwarded to
        # journal (stderr is what's relevant in the pristine corosync configuration),
        # which hazards a message redundancy since the syslog stream usually ends there
        # as well; before editing this line, you may want to check DefaultStandardError
        # in systemd-system.conf(5) and whether /dev/log is a systemd related symlink.
        StandardError = "null";

        # The following config is for corosync with enabled watchdog service.
        #
        #  When corosync watchdog service is being enabled and using with
        #  pacemaker.service, and if you want to exert the watchdog when a
        #  corosync process is terminated abnormally,
        #  uncomment the line of the following Restart= and RestartSec=.
        #Restart=on-failure
        #  Specify a period longer than soft_margin as RestartSec.
        #RestartSec=70
        #  rewrite according to environment.
        #ExecStartPre=/sbin/modprobe softdog
        PrivateTmp = "yes";
      };
    };
  };

  systemd.tmpfiles.rules = [ "d /etc/corosync 0755 root root -" ];
}
