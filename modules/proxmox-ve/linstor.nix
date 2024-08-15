{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.proxmox-ve.linstor;
in

{
  meta.maintainers = with maintainers; [
    julienmalka
    camillemndn
  ];

  options.services.proxmox-ve.linstor.enable = mkEnableOption "Linstor for Proxmox VE";

  config = mkIf cfg.enable {
    services.proxmox-ve.package = pkgs.proxmox-ve.override { enableLinstor = true; };

    systemd.services = {
      linstor-controller = {
        description = "Linstor Controller";
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        before = [ "pvedaemon.service" ];
        serviceConfig = {
          Type = "notify";
          ExecStart = "${pkgs.linstor-server}/bin/linstor-controller";
          Restart = "on-failure";
          # if killed by signal 143 -> SIGTERM, 129 -> SIGHUP
          SuccessExitStatus = "0 143 129";
          PrivateTmp = true;
        };
      };

      linstor-satellite = {
        description = "LINSTOR Satellite Service";
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        before = [ "pvedaemon.service" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.linstor-server}/bin/linstor-satellite --logs=/var/log/linstor-satellite --config-directory=/etc/linstor";
          SuccessExitStatus = "0 143 129";
          PrivateTmp = true;
        };
      };
    };
  };
}
