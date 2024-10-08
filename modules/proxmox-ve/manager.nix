{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.proxmox-ve;
in

lib.mkIf cfg.enable {
  systemd.services = {
    pvedaemon = {
      description = "PVE API Daemon";
      wants = [
        "corosync.service"
        "pve-cluster.service"
      ];
      after = [
        "corosync.service"
        "pve-cluster.service"
      ];
      path = with pkgs; [ btrfs-progs zfs ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/pvedaemon start";
        ExecStop = "${cfg.package}/bin/pvedaemon stop";
        ExecReload = "${cfg.package}/bin/pvedaemon restart";
        PIDFile = "/run/pvedaemon.pid";
        Type = "forking";
        Restart = "on-failure";
        CacheDirectory = "linstor-proxmox";
      };
    };

    pveproxy = {
      description = "PVE API Proxy Server";
      wants = [
        "pve-cluster.service"
        "pvedaemon.service"
        "sshd.service"
        "pve-storage.target"
      ];
      after = [
        "pve-storage.target"
        "pve-cluster.service"
        "pvedaemon.service"
        "sshd.service"
      ];
      serviceConfig = {
        ExecStartPre = [
          "${cfg.package}/bin/pvecm updatecerts -silent"
          "${pkgs.coreutils}/bin/touch /var/lock/pveproxy.lck"
          "${pkgs.coreutils}/bin/chown -R www-data:www-data /var/lock/pveproxy.lck"
        ];
        ExecStart = "${cfg.package}/bin/pveproxy start";
        ExecStop = "${cfg.package}/bin/pveproxy stop";
        ExecReload = "${cfg.package}/bin/pveproxy restart";
        PIDFile = "/run/pveproxy/pveproxy.pid";
        Type = "forking";
        StateDirectory = "pve-manager";
        Restart = "on-failure";
      };
    };

    pve-guests = {
      description = "PVE guests";
      environment.PVE_LOG_ID = "pve-guests";
      wantedBy = [ "multi-user.target" ];
      wants = [
        "pvestatd.service"
        "pveproxy.service"
        "spiceproxy.service"
        "pve-firewall.service"
        "lxc.service"
      ];
      after = [
        "pveproxy.service"
        "pvestatd.service"
        "spiceproxy.service"
        "pve-firewall.service"
        "lxc.service"
        "pve-ha-crm.service"
        "pve-ha-lrm.service"
      ];
      unitConfig = {
        RefuseManualStart = true;
        RefuseManualStop = true;
      };
      serviceConfig = {
        #ExecStartPre = "${cfg.package}/share/pve-manager/helpers/pve-startall-delay";
        ExecStart = "${cfg.package}/bin/pvesh --nooutput create /nodes/localhost/startall";
        ExecStop = pkgs.writeShellScript "pve-guests-stop" ''
          -${cfg.package}/bin/vzdump -stop
          ${cfg.package}/bin/pvesh --nooutput create /nodes/localhost/stopall
        '';
        Type = "oneshot";
        RemainAfterExit = true;
        #TimeoutSec = "infinity";
      };
    };

    pvebanner = {
      description = "Proxmox VE Login Banner";
      wantedBy = [ "multi-user.target" ];
      unitConfig = {
        DefaultDependencies = false;
        After = [ "local-fs.target" ];
        Before = [ "console-getty.service" ];
      };
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/pvebanner";
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };

    pvescheduler = {
      description = "Proxmox VE scheduler";
      wantedBy = [ "multi-user.target" ];
      wants = [ "pve-cluster.service" ];
      after = [
        "pve-cluster.service"
        "pve-guests.service"
        "pve-storage.target"
      ];
      serviceConfig = {
        ExecStartPre = [
          "${pkgs.coreutils}/bin/touch /var/lib/pve-manager/pve-replication-state.lck"
          "${pkgs.coreutils}/bin/chown -R www-data:www-data /var/lib/pve-manager/pve-replication-state.lck"
        ];
        ExecStart = "${cfg.package}/bin/pvescheduler start";
        ExecStop = "${cfg.package}/bin/pvescheduler stop";
        ExecReload = "${cfg.package}/bin/pvescheduler restart";
        PIDFile = "/var/run/pvescheduler.pid";
        KillMode = "process";
        Type = "forking";
      };
    };

    pvestatd = {
      description = "PVE Status Daemon";
      wants = [ "pve-cluster.service" ];
      after = [ "pve-cluster.service" ];
      path = with pkgs; [ btrfs-progs zfs ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/pvestatd start";
        ExecStop = "${cfg.package}/bin/pvestatd stop";
        ExecReload = "${cfg.package}/bin/pvestatd restart";
        PIDFile = "/run/pvestatd.pid";
        Type = "forking";
      };
    };

    # pvenetcommit = {
    #   description = "Commit Proxmox VE network changes";
    #   wantedBy = [ "multi-user.target" ];
    #   environment.FN = "/etc/network/interfaces";
    #   unitConfig = {
    #     DefaultDependencies = false;
    #     After = "local-fs.target";
    #     Before = "sysinit.target";
    #   };
    #   serviceConfig = {
    #     ExecStartPre = "${pkgs.coreutils}/bin/rm -f /etc/openvswitch/conf.db";
    #     ExecStart = "${pkgs.bash}/bin/sh -c 'if [ -f $FN.new ]; then ${pkgs.coreutils}/bin/mv $FN.new $FN; fi'";
    #     Type = "oneshot";
    #     RemainAfterExit = true;
    #   };
    # };

    # spiceproxy = { };
  };

  systemd.tmpfiles.rules = [ "d /var/log/pveproxy 0755 www-data www-data -" ];

  systemd.targets = {
    pve-storage = {
      description = "PVE Storage Target";
      unitConfig = {
        Wants = [ "remote-fs.target" ];
        After = [
          "remote-fs.target"
          "ceph.target"
          "ceph-mon.target"
          "ceph-osd.target"
          "ceph-mds.target"
          "ceph-mgr.target"
          "glusterd.service"
          "open-iscsi.service"
        ];
      };
    };
  };
}
