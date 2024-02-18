{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.proxmox-ve;
in

{
  meta.maintainers = with maintainers; [ julienmalka camillemndn ];

  options.services.proxmox-ve = {
    enable = mkEnableOption (mdDoc ''Proxmox VE'');
    localIP = mkOption {
      description = mdDoc ''Local IP'';
      type = types.str;
      example = "192.168.0.2";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (import ./cluster.nix { inherit pkgs; })
    # (import ./firewall.nix { inherit pkgs; })
    # (import ./ha-manager.nix { inherit pkgs; })
    (import ./manager.nix { inherit pkgs; })
    {
      boot.supportedFilesystems = [ "fuse" "glusterfs" ];
      networking.hosts = { "${cfg.localIP}" = [ config.networking.hostName ]; };
      services.rpcbind.enable = true;
      services.rrdcached.enable = true;
      users.users.www-data = { isSystemUser = true; group = "www-data"; };
      users.groups.www-data = { };
      environment.systemPackages = [ pkgs.proxmox-ve ];
      environment.etc.issue.enable = false;
      networking.firewall.allowedTCPPorts = [ 8006 111 80 443 ];
    }
  ]);
}
