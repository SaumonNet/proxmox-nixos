{ monitors }:

let
  node = ipAddress: osdIds: { config, lib, ... }: {
    services.proxmox-ve = {
      enable = true;
      inherit ipAddress;
      ceph = {
        enable = true;
        mon.enable = builtins.elem config.networking.hostName monitors;
        # Proxmox creates a manager on the first monitor.
        mgr.enable = config.networking.hostName == builtins.head monitors;
        osd.enable = osdIds != [ ];
        osd.daemons = osdIds;
      };
    };
    # Give the two OSDs on the batch-provisioned disk 6 GiB each.
    virtualisation.emptyDiskImages = lib.optional (osdIds != [ ]) 12288;
  };
in
{
  inherit node;

  module = {
    globalTimeout = 10 * 60;

    defaults = { lib, pkgs, ... }: {
      environment.systemPackages = [
        pkgs.ceph
        pkgs.jq
      ];
      # The isolated guests need a common clock to stay within Ceph's monitor skew limit.
      services.chrony = {
        enable = true;
        servers = lib.mkDefault [ "192.168.1.1" ];
        makestep.threshold = 0.01;
      };
      virtualisation.memorySize = 2048;
    };

    nodes = {
      pve1 = { pkgs, ... }: {
        imports = [ (node "192.168.1.1" [ "0" ]) ];
        services.chrony = {
          servers = [ ];
          extraConfig = ''
            local stratum 8
            allow 192.168.1.0/24
          '';
        };
        networking.firewall.allowedUDPPorts = [ 123 ];
        environment.systemPackages = [ pkgs.openssl ];
        users.users.root = {
          password = "mypassword";
          initialPassword = null;
          hashedPassword = null;
          hashedPasswordFile = null;
        };
      };
      pve2 = node "192.168.1.2" [ "1" ];
      pve3 = node "192.168.1.3" [ "2" "3" ];
    };
  };

  setupScript = ''
    import json

    monitors = [${builtins.concatStringsSep ", " monitors}]

    def wait_for_quorum(members):
        names = json.dumps(sorted(host.name for host in members))
        pve1.wait_until_succeeds(
            f"ceph quorum_status -f json | jq -e '(.quorum_names | sort) == {names}'"
        )

    def wait_for_osds(up=4):
        pve1.wait_until_succeeds(
            "ceph osd stat -f json | jq -e "
            f"'.num_osds == 4 and .num_up_osds == {up} and .num_in_osds == 4'"
        )

    def wait_for_health():
        try:
            wait_for_quorum(monitors)
            pve1.wait_until_succeeds(
                "ceph status -f json | jq -e '"
                ".health.status == \"HEALTH_OK\" and "
                "(.pgmap.pgs_by_state | map(.state_name)) == [\"active+clean\"]'",
                timeout=120,
            )
        finally:
            print(pve1.succeed("ceph status"))

    start_all()
    with subtest("Form the Proxmox cluster"):
        pve1.wait_for_unit("pveproxy.service")
        pve1.succeed("pvecm create mycluster")
        quorate = "pvecm status | grep -E '^Quorate: +Yes$'"
        pve1.wait_until_succeeds(quorate)
        fingerprint = pve1.succeed(
            "openssl x509 -noout -fingerprint -sha256 -in /etc/pve/local/pve-ssl.pem | cut -d= -f2"
        ).strip()
        for peer in machines:
            if peer is pve1:
                continue
            peer.wait_for_unit("multi-user.target")
            peer.succeed(
                "pvesh create /cluster/config/join --hostname 192.168.1.1 "
                f"--fingerprint {fingerprint} --password mypassword"
            )
            peer.wait_until_succeeds(quorate)
            pve1.wait_until_succeeds(f"pvecm nodes | grep -w {peer.name}")

    with subtest("Create monitors and OSDs through Proxmox"):
        pve1.succeed("pveceph init --network 192.168.1.0/24")
        for count, host in enumerate(monitors, start=1):
            host.succeed("pveceph mon create")
            wait_for_quorum(monitors[:count])
        pve1.succeed("pveceph osd create /dev/vdb")
        pve2.succeed("pveceph osd create /dev/vdb")
        pve3.succeed("pveceph osd create /dev/vdb --osds-per-device 2")
        wait_for_osds()
  '';
}
