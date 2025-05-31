{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.proxmox-ve.enable {
  systemd.slices = {
    "system-pve\\x2dcontainer" = {
      description = "PVE LXC Container Slice";
      documentation = ["man:pct"];

      unitConfig = {
        DefaultDependencies="no";
      };
    };
  };

  systemd.services = {
    lxc-monitord = {
      description = "LXC Container Monitoring Daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "syslog.service" "network.target"];

      documentation = ["man:lxc"];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.lxc}/libexec/lxc/lxc-monitord --daemon";
      };
    };

    pve-lxc-syscalld = {
      description = "Proxmox VE LXC Syscall Daemon";
      wantedBy = [ "multi-user.target" ];
      before = [ "pve-guests.service" ];
      serviceConfig = {
        Type = "notify";
        ExecStart = "${pkgs.pve-lxc-syscalld}/bin/pve-lxc-syscalld --system /run/pve/lxc-syscalld.sock";
        RuntimeDirectory = "pve";
        Restart = "on-failure";
      };
    };

    "pve-container-debug@" = {
      # based on lxc@.service, but without an install section because
      # starting and stopping should be initiated by PVE code, not
      # systemd.
      description = "PVE LXC Container: %i";
      after = [ "lxc.service" ];
      wants = [ "lxc.service" ];
      unitConfig = {
        DefaultDependencies = false;
        Documentation = "man:lxc-start man:lxc man:pct";
        serviceConfig = {
          Type = "simple";
          Delegate = true;
          KillMode = "mixed";
          TimeoutStopSec = 120;
          ExecStart = "${pkgs.lxc}/bin/lxc-start -F -n %i -o /dev/stderr -l DEBUG";
          ExecStop = "${pkgs.pve-container}/share/lxc/pve-container-stop-wrapper %i";
          # Environment=BOOTUP=serial
          # Environment=CONSOLETYPE=serial
          # Prevent container init from putting all its output into the journal
          StandardOutput = null;
          StandardError = "file:/run/pve/ct-%i.stderr";
        };
      };

      "pve-container@" = {
        # based on lxc@.service, but without an install section because
        # starting and stopping should be initiated by PVE code, not
        # systemd.
        description = "PVE LXC Container: %i";
        after = [ "lxc.service" ];
        wants = [ "lxc.service" ];
        unitConfig = {
          DefaultDependencies = false;
          Documentation = "man:lxc-start man:lxc man:pct";
        };
        serviceConfig = {
          Type = "simple";
          Delegate = true;
          KillMode = "mixed";
          TimeoutStopSec = 120;
          ExecStart = "${pkgs.lxc}/bin/lxc-start -F -n %i";
          ExecStop = "${pkgs.pve-container}/share/lxc/pve-container-stop-wrapper %i";
          # Environment=BOOTUP=serial
          # Environment=CONSOLETYPE=serial
          # Prevent container init from putting all its output into the journal
          StandardOutput = null;
          StandardError = "file:/run/pve/ct-%i.stderr";
        };
      };
    };
  };
}
