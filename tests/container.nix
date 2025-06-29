{ pkgs, ... }:

let
  alpineTemplate = pkgs.fetchurl {
    url = "http://download.proxmox.com/images/system/alpine-3.21-default_20241217_amd64.tar.xz";
    hash = "sha256-E7AucUeLh7B41c7UuChKAY6Kv5z9fqvQl8z37X7+D60=";
  };
in
{
  name = "pve-container";

  nodes.mypve = {
    networking = {
      useNetworkd = true;
      firewall.enable = false;
    };
    #services.resolved.enable = true;
    systemd.services.systemd-networkd.environment.SYSTEMD_LOG_LEVEL = "debug";
    systemd.network = {
      enable = true;
      netdevs = {
        "vmbr0" = {
          netdevConfig = {
            Name = "vmbr0";
            Kind = "bridge";
          };
        };
      };

    networks."10-lan-bridge" = {
      matchConfig.Name = "vmbr0";
      networkConfig = {
        Address = "10.10.10.10/24";
        Gateway = "10.10.10.254";
        DNS = [ "8.8.8.8" ];
      };
      linkConfig.RequiredForOnline = "routable";
    };
    };

    services.proxmox-ve = {
      enable = true;
      ipAddress = "192.168.1.1";

      bridges = [ "vmbr0" ];
    };

    users.users.root = {
      subUidRanges = [
        {
          count = 65536;
          startUid = 100000;
        }
      ];
      subGidRanges = [
        {
          count = 65536;
          startGid = 100000;
        }
      ];
    };
  };

  testScript = ''
   machine.start()
   machine.wait_for_unit("pveproxy.service")
   machine.succeed("mkdir -p /var/lib/vz/template/cache/")
   machine.succeed("cp ${alpineTemplate} /var/lib/vz/template/cache/alpine-3.21-default_20241217_amd64.tar.xz")
   machine.succeed("pveam list local")
   args = (
       "150",
       "local:vztmpl/alpine-3.21-default_20241217_amd64.tar.xz",
       "--hostname=alpine-test",
       "--ostype=alpine",
       "--unprivileged=1",
       "--net0 name=eth0,bridge=vmbr0,ip=dhcp",
       "--storage=local"
   )
   machine.succeed(f"pct create {' '.join(args)}")
   machine.succeed("pct start 150")
   assert "running" in machine.succeed("pct list")
   machine.succeed("pct stop 150")
   assert "stopped" in machine.succeed("pct list")
   machine.succeed("pct destroy 150")
  '';
}
