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
      description = "RRD update cache";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
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
