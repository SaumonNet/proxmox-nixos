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

  options.services.proxmox-ve.linstor = {
    enable = mkEnableOption "Linstor for Proxmox VE";
    openFirewall = mkEnableOption "opening the default ports in the firewall for Linstor Satellite";
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = with config.boot.kernelPackages; [ drbd ];
    boot.kernelModules = [
      "dm_thin_pool"
      "drbd"
    ];

    services.drbd = {
      enable = true;
      config = ''
            global {
        	usage-count yes;

        	# Decide what kind of udev symlinks you want for "implicit" volumes
        	# (those without explicit volume <vnr> {} block, implied vnr=0):
        	# /dev/drbd/by-resource/<resource>/<vnr>   (explicit volumes)
        	# /dev/drbd/by-resource/<resource>         (default for implict)
        	udev-always-use-vnr; # treat implicit the same as explicit volumes

        	# minor-count dialog-refresh disable-ip-verification
        	# cmd-timeout-short 5; cmd-timeout-medium 121; cmd-timeout-long 600;
        }
        include "/var/lib/linstor.d/*.res";
      '';
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
      3366
      3367
    ];

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
