{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.proxmox-ve;
in

{
  meta.maintainers = with maintainers; [
    julienmalka
    camillemndn
  ];

  imports = [
    ./cluster.nix
    # ./firewall.nix
    # ./ha-manager.nix
    ./manager.nix
    ./rrdcached.nix
  ];

  options.services.proxmox-ve.enable = mkEnableOption (mdDoc ''Proxmox VE'');

  config = mkIf cfg.enable (mkMerge [
    {
      boot.supportedFilesystems = [
        "fuse"
        "glusterfs"
      ];

      networking.hosts = {
        "127.0.0.2" = lib.mkForce [ ];
        "::1" = lib.mkForce [ ];
      };

      # create the /etc/network/interfaces file for proxmox
      systemd.tmpfiles.rules = [
        "d /etc/network 0755 root root -"
        "f /etc/network/interfaces 0755 root root -"
      ];

      services.openssh = {
        enable = true;
        settings.AcceptEnv = "LANG LC_*";
      };
      programs.ssh.extraConfig = ''
        SendEnv LANG LC_*
      '';

      security.pam.services."proxmox-ve-auth" = {
        logFailures = true;
        nodelay = true;
      };

      services.rpcbind.enable = true;
      services.rrdcached.enable = true;

      users.users.www-data = {
        isSystemUser = true;
        group = "www-data";
      };
      users.groups.www-data = { };

      environment.systemPackages = [ pkgs.proxmox-ve ];
      environment.etc.issue.enable = false;

      networking.firewall.allowedTCPPorts = [
        80
        111
        443
        8006
      ];
    }
  ]);
}
