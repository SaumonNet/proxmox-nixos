{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.proxmox-backup;
in

{
  meta.maintainers = with maintainers; [
    julienmalka
    camillemndn
  ];

  options.services.proxmox-backup = {
    enable = mkEnableOption (mdDoc ''Proxmox VE'');
    localIP = mkOption {
      description = mdDoc ''Local IP'';
      type = types.str;
      example = "192.168.0.2";
    };
  };

  config = mkIf cfg.enable {
    systemd.services = {
      proxmox-backup-banner = {
        description = "Proxmox Backup Server Login Banner";
        unitConfig = {
          DefaultDependencies = "no";
          After = "local-fs.target";
          Before = "console-getty.service";
        };
        serviceConfig = {
          ExecStart = "${pkgs.proxmox-backup}/bin/proxmox-backup-banner";
          Type = "oneshot";
          RemainAfterExit = "yes";
        };
        wantedBy = [ "getty.target" ];
      };
      proxmox-backup-proxy = {
        description = "Proxmox Backup API Proxy Server";
        unitConfig = {
          Wants = [
            "network-online.target"
            "proxmox-backup.service"
          ];
          After = [
            "network.target"
            "proxmox-backup.service"
          ];
        };
        serviceConfig = {
          Type = "notify";
          ExecStart = "${pkgs.proxmox-backup}/bin/proxmox-backup-proxy";
          ExecReload = "/bin/kill -HUP $MAINPID";
          PIDFile = "/run/proxmox-backup/proxy.pid";
          Restart = "on-failure";
          User = "backup";
          Group = "backup";
        };

        wantedBy = [ "multi-user.target" ];
      };
      proxmox-backup = {
        description = "Proxmox Backup API Server";
        unitConfig = {
          Wants = [ "network-online.target" ];
          After = [ "network.target" ];
        };
        serviceConfig = {
          Type = "notify";
          ExecStart = "${pkgs.proxmox-backup}/bin/proxmox-backup-api";
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          PIDFile = "/run/proxmox-backup/api.pid";
          Restart = "on-failure";
        };
        wantedBy = [ "multi-user.target" ];
      };
    };

    users.users.backup = {
      isSystemUser = true;
      group = "backup";
    };
    users.groups.backup = { };

    environment.systemPackages = [ pkgs.proxmox-backup ];
    environment.etc.issue.enable = false;

    networking.firewall.allowedTCPPorts = [
      8007
      111
      80
      443
    ];
  };
}
