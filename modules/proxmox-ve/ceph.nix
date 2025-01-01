{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.proxmox-ve.ceph;

  makeServices =
    daemonType: daemonIds:
    lib.mkMerge (
      map (daemonId: {
        "ceph-${daemonType}-${daemonId}" = makeService daemonType daemonId "ceph" cfg.${daemonType}.package;
      }) daemonIds
    );

  makeService =
    daemonType: daemonId: clusterName: ceph:
    let
      stateDirectory = "ceph/${
        if daemonType == "rgw" then "radosgw" else daemonType
      }/${clusterName}-${daemonId}";
    in
    {
      enable = true;
      description = "Ceph ${
        builtins.replaceStrings lib.lowerChars lib.upperChars daemonType
      } daemon ${daemonId}";
      after = [
        "network-online.target"
        "time-sync.target"
        "pve-cluster.service"
      ] ++ lib.optional (daemonType == "osd") "ceph-mon.target";
      wants = [
        "network-online.target"
        "time-sync.target"
      ];
      partOf = [ "ceph-${daemonType}.target" ];
      wantedBy = [ "ceph-${daemonType}.target" ];

      path = [ pkgs.getopt ];

      # Don't start services that are not yet initialized
      unitConfig.ConditionPathExists = "/var/lib/${stateDirectory}/keyring";
      startLimitBurst =
        if daemonType == "osd" then
          30
        else if
          lib.elem daemonType [
            "mgr"
            "mds"
          ]
        then
          3
        else
          5;
      startLimitIntervalSec = 60 * 30; # 30 mins

      serviceConfig =
        {
          LimitNOFILE = 1048576;
          LimitNPROC = 1048576;
          Environment = "CLUSTER=${clusterName}";
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          PrivateDevices = "yes";
          PrivateTmp = "true";
          ProtectHome = "true";
          ProtectSystem = "full";
          Restart = "on-failure";
          ExecStart = ''
            ${ceph.out}/bin/${if daemonType == "rgw" then "radosgw" else "ceph-${daemonType}"} \
                                -f --cluster ${clusterName} --id ${daemonId} --setuser ceph --setgroup ceph'';
        }
        // lib.optionalAttrs (daemonType == "osd") {
          ExecStartPre = "${ceph.lib}/libexec/ceph/ceph-osd-prestart.sh --id ${daemonId} --cluster ${clusterName}";
          RestartSec = "20s";
          PrivateDevices = "no"; # osd needs disk access
        }
        // lib.optionalAttrs (daemonType == "mon") {
          RestartSec = "10";
        };
    };

  makeTarget = daemonType: {
    "ceph-${daemonType}" = {
      description = "Ceph target allowing to start/stop all ceph-${daemonType} services at once";
      partOf = [ "ceph.target" ];
      wantedBy = [ "ceph.target" ];
      before = [ "ceph.target" ];
      unitConfig.StopWhenUnneeded = true;
    };
  };
in

{
  options.services.proxmox-ve.ceph = {
    enable = lib.mkEnableOption "Ceph global configuration";

    mgr = {
      enable = lib.mkEnableOption "Ceph MGR daemon";
      package = lib.mkPackageOption pkgs "ceph" { };
      daemons = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ config.networking.hostName ];
        example = [
          "name1"
          "name2"
        ];
        description = ''
          A list of names for manager daemons that should have a service created. The names correspond
          to the id part in ceph i.e. [ "name1" ] would result in mgr.name1
        '';
      };
    };

    mon = {
      enable = lib.mkEnableOption "Ceph MON daemon";
      package = lib.mkPackageOption pkgs "ceph" { };
      daemons = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ config.networking.hostName ];
        example = [
          "name1"
          "name2"
        ];
        description = ''
          A list of monitor daemons that should have a service created. The names correspond
          to the id part in ceph i.e. [ "name1" ] would result in mon.name1
        '';
      };
    };

    osd = {
      enable = lib.mkEnableOption "Ceph OSD daemon";
      package = lib.mkPackageOption pkgs "ceph" { };
      daemons = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        example = [
          "1"
          "2"
        ];
        description = ''
          A list of OSD daemons that should have a service created. The names correspond
          to the id part in ceph i.e. [ "1" ] would result in osd.1
        '';
      };
    };

    mds = {
      enable = lib.mkEnableOption "Ceph MDS daemon";
      package = lib.mkPackageOption pkgs "ceph" { };
      daemons = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        example = [
          "name1"
          "name2"
        ];
        description = ''
          A list of metadata service daemons that should have a service created. The names correspond
          to the id part in ceph i.e. [ "name1" ] would result in mds.name1
        '';
      };
    };

    rgw = {
      enable = lib.mkEnableOption "Ceph RadosGW daemon";
      package = lib.mkPackageOption pkgs "ceph" { };
      daemons = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        example = [
          "name1"
          "name2"
        ];
        description = ''
          A list of rados gateway daemons that should have a service created. The names correspond
          to the id part in ceph i.e. [ "name1" ] would result in client.name1, radosgw daemons
          aren't daemons to cluster in the sense that OSD, MGR or MON daemons are. They are simply
          daemons, from ceph, that uses the cluster as a backend.
        '';
      };
    };
  };

  config = lib.mkIf config.services.proxmox-ve.ceph.enable {
    assertions = [
      {
        assertion = cfg.enable -> !config.services.ceph.enable;
        message = "Ceph for Proxmox VE is not compatible with the Ceph module for NixOS";
      }
      {
        assertion = cfg.mon.enable -> cfg.mon.daemons != [ ];
        message = "have to set id of atleast one MON if you're going to enable Monitor";
      }
      {
        assertion = cfg.mds.enable -> cfg.mds.daemons != [ ];
        message = "have to set id of atleast one MDS if you're going to enable Metadata Service";
      }
      {
        assertion = cfg.osd.enable -> cfg.osd.daemons != [ ];
        message = "have to set id of atleast one OSD if you're going to enable OSD";
      }
      {
        assertion = cfg.mgr.enable -> cfg.mgr.daemons != [ ];
        message = "have to set id of atleast one MGR if you're going to enable MGR";
      }
    ];

    networking.firewall = lib.mkIf config.services.proxmox-ve.openFirewall {
      allowedTCPPorts = lib.optionals cfg.mon.enable [
          3300
          6789
        ];
      allowedTCPPortRanges = lib.optionals (cfg.osd.enable || cfg.msd.enable || cfg.mgr.enable) [
        {
          from = 6800;
          to = 7300;
        }
      ];
    };

    users.users.ceph = {
      uid = config.ids.uids.ceph;
      description = "Ceph daemon user";
      group = "ceph";
      extraGroups = [ "disk" ];
    };

    users.groups.ceph = {
      gid = config.ids.gids.ceph;
    };

    systemd.services =
      let
        services =
          lib.optional cfg.mon.enable (makeServices "mon" cfg.mon.daemons)
          ++ lib.optional cfg.mds.enable (makeServices "mds" cfg.mds.daemons)
          ++ lib.optional cfg.osd.enable (makeServices "osd" cfg.osd.daemons)
          ++ lib.optional cfg.rgw.enable (makeServices "rgw" cfg.rgw.daemons)
          ++ lib.optional cfg.mgr.enable (makeServices "mgr" cfg.mgr.daemons);
      in
      lib.mkMerge services;

    systemd.targets =
      let
        targets =
          [
            {
              ceph = {
                description = "Ceph target allowing to start/stop all ceph service instances at once";
                wantedBy = [ "multi-user.target" ];
                unitConfig.StopWhenUnneeded = true;
              };
            }
          ]
          ++ lib.optional cfg.mon.enable (makeTarget "mon")
          ++ lib.optional cfg.mds.enable (makeTarget "mds")
          ++ lib.optional cfg.osd.enable (makeTarget "osd")
          ++ lib.optional cfg.rgw.enable (makeTarget "rgw")
          ++ lib.optional cfg.mgr.enable (makeTarget "mgr");
      in
      lib.mkMerge targets;

    systemd.tmpfiles.settings."10-ceph" =
      let
        defaultConfig = {
          user = "ceph";
          group = "ceph";
        };
      in
      {
        "/etc/ceph".d = defaultConfig;
        "/run/ceph".d = defaultConfig // {
          mode = "0770";
        };
        "/var/lib/ceph".d = defaultConfig;
        "/var/lib/ceph/mgr".d = lib.mkIf cfg.mgr.enable defaultConfig;
        "/var/lib/ceph/mon".d = lib.mkIf cfg.mon.enable defaultConfig;
        "/var/lib/ceph/osd".d = lib.mkIf cfg.osd.enable defaultConfig;
        "/var/lib/ceph/bootstrap-mgr".d = lib.mkIf cfg.mgr.enable defaultConfig;
        "/var/lib/ceph/bootstrap-mon".d = lib.mkIf cfg.mon.enable defaultConfig;
        "/var/lib/ceph/bootstrap-osd".d = lib.mkIf cfg.osd.enable defaultConfig;
        "/var/lib/ceph/bootstrap-rgw".d = lib.mkIf cfg.rgw.enable defaultConfig;
        "/var/lib/ceph/bootstrap-mds".d = lib.mkIf cfg.mds.enable defaultConfig;
      };
  };
}
