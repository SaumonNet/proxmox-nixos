{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.proxmox-ve.enable {
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
      serviceConfig = {
        ExecStart = "${pkgs.pve-manager}/bin/pvedaemon start";
        ExecStop = "${pkgs.pve-manager}/bin/pvedaemon stop";
        ExecReload = "${pkgs.pve-manager}/bin/pvedaemon restart";
        PIDFile = "/run/pvedaemon.pid";
        Type = "forking";
        Restart = "on-failure";
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
          "${pkgs.pve-cluster}/bin/pvecm updatecerts -silent"
          "${pkgs.coreutils}/bin/touch /var/lock/pveproxy.lck"
          "${pkgs.coreutils}/bin/chown -R www-data:www-data /var/lock/pveproxy.lck"
        ];
        ExecStart = "${pkgs.pve-manager}/bin/pveproxy start";
        ExecStop = "${pkgs.pve-manager}/bin/pveproxy stop";
        ExecReload = "${pkgs.pve-manager}/bin/pveproxy restart";
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
        "qmeventd.service"
        "pveproxy.service"
        "spiceproxy.service"
        "pve-firewall.service"
        "lxc.service"
      ];
      after = [
        "pveproxy.service"
        "pvestatd.service"
        "qmeventd.service"
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
        #ExecStartPre = "${pkgs.pve-manager}/share/pve-manager/helpers/pve-startall-delay";
        ExecStart = "${pkgs.pve-manager}/bin/pvesh --nooutput create /nodes/localhost/startall";
        ExecStop = pkgs.writeShellScript "pve-guests-stop" ''
          -${pkgs.pve-manager}/bin/vzdump -stop
          ${pkgs.pve-manager}/bin/pvesh --nooutput create /nodes/localhost/stopall
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
        ExecStart = "${pkgs.pve-manager}/bin/pvebanner";
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
        ExecStart = "${pkgs.pve-manager}/bin/pvescheduler start";
        ExecStop = "${pkgs.pve-manager}/bin/pvescheduler stop";
        ExecReload = "${pkgs.pve-manager}/bin/pvescheduler restart";
        PIDFile = "/var/run/pvescheduler.pid";
        KillMode = "process";
        Type = "forking";
      };
    };

    pvestatd = {
      description = "PVE Status Daemon";
      wants = [ "pve-cluster.service" ];
      after = [ "pve-cluster.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.pve-manager}/bin/pvestatd start";
        ExecStop = "${pkgs.pve-manager}/bin/pvestatd stop";
        ExecReload = "${pkgs.pve-manager}/bin/pvestatd restart";
        PIDFile = "/run/pvestatd.pid";
        Type = "forking";
      };
    };

    qmeventd = {
      description = "PVE Qemu Event Daemon";
      before = [ "pve-ha-lrm.service" "pve-guests.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.proxmox-ve}/bin/qmeventd /var/run/qmeventd.sock";
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
