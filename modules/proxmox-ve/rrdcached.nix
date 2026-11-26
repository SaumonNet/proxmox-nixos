{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.rrdcached;
in

{
  meta.maintainers = with maintainers; [
    julienmalka
    camillemndn
  ];

  options.services.rrdcached = {
    enable = mkEnableOption (mdDoc ''RRD Cache Daemon'');
  };

  config = mkIf cfg.enable {
    systemd.services.rrdcached = {
      description = "LSB: start or stop rrdcached";
      before = [
        "multi-user.target"
        "graphical.target"
      ];
      after = [
        "remote-fs.target"
        "nss-lookup.target"
        "time-sync.target"
        "network-online.target"
      ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      unitConfig = {
        Documentation = "man:systemd-sysv-generator(8)";
        SourcePath = "${pkgs.rrdtool}/bin/rrdcached";
      };
      serviceConfig = {
        Restart = "no";
        TimeoutSec = "5min";
        IgnoreSIGPIPE = false;
        KillMode = "process";
        StateDirectory = [
          "rrdcached/db"
          "rrdcached/journal"
        ];
        ExecStart = "${pkgs.rrdtool}/bin/rrdcached -g"
          + " -b /var/lib/rrdcached/db -j /var/lib/rrdcached/journal"
          + " -l /run/rrdcached.sock -p /run/rrdcached.pid";
      };
    };
  };
}
