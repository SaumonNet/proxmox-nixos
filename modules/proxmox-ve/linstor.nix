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
          ExecStart = "${pkgs.linstor-server}/bin/linstor-controller";
          Type = "notify";
          PrivateTmp = true;
          SuccessExitStatus = "0 143 129";
          Restart = "on-failure";
        };
      };

    };

  };
}
