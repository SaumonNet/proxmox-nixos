let
  node = ipAddress: osdId: {
    services.proxmox-ve = {
      enable = true;
      inherit ipAddress;
      ceph = {
        enable = true;
        mon.enable = true;
        osd.enable = true;
        osd.daemons = [ osdId ];
      };
    };
  };
in
{
  name = "pve-ceph";
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
    virtualisation = {
      emptyDiskImages = [ 1024 ];
      memorySize = 2048;
    };
  };

  nodes = {
    pve1 = { pkgs, ... }: {
      imports = [ (node "192.168.1.1" "0") ];
      services.proxmox-ve.ceph.mgr.enable = true;
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
    pve2 = node "192.168.1.2" "1";
    pve3 = node "192.168.1.3" "2";
  };

  testScript = ''
    def wait_for_osds(up=3):
        pve1.wait_until_succeeds(
            "ceph osd stat -f json | jq -e "
            f"'.num_osds == 3 and .num_up_osds == {up} and .num_in_osds == 3'"
        )

    def wait_for_health():
        try:
            pve1.wait_until_succeeds(
                "ceph status -f json | jq -e '"
                ".health.status == \"HEALTH_OK\" and (.quorum_names | length) == 3 and "
                "(.pgmap.pgs_by_state | map(.state_name)) == [\"active+clean\"]'",
                timeout=120,
            )
        finally:
            print(pve1.succeed("ceph status"))

    start_all()
    with subtest("Form a three-node Proxmox cluster"):
        pve1.wait_for_unit("pveproxy.service")
        pve1.succeed("pvecm create mycluster")
        quorate = "pvecm status | grep -E '^Quorate: +Yes$'"
        pve1.wait_until_succeeds(quorate)
        fingerprint = pve1.succeed(
            "openssl x509 -noout -fingerprint -sha256 -in /etc/pve/local/pve-ssl.pem | cut -d= -f2"
        ).strip()
        for peer in (pve2, pve3):
            peer.wait_for_unit("multi-user.target")
            peer.succeed(
                "pvesh create /cluster/config/join --hostname 192.168.1.1 "
                f"--fingerprint {fingerprint} --password mypassword"
            )
            peer.wait_until_succeeds(quorate)
            pve1.wait_until_succeeds(f"pvecm nodes | grep -w {peer.name}")

    with subtest("Create monitors and OSDs through Proxmox"):
        pve1.succeed("pveceph init --network 192.168.1.0/24")
        for index, host in enumerate((pve1, pve2, pve3), start=1):
            host.succeed(f"pveceph mon create --mon-address 192.168.1.{index}")
            pve1.wait_until_succeeds(
                f"ceph quorum_status -f json | jq -e '.quorum_names | index(\"{host.name}\") != null'"
            )
            host.succeed("pveceph osd create /dev/vdb")
        wait_for_osds()

    with subtest("Read a replicated object from another node"):
        # Start this small pool at the Ceph autoscaler's default minimum.
        pve1.succeed("pveceph pool create testpool --size 3 --pg_num 32")
        wait_for_health()
        pve1.succeed("printf 'Ceph cluster test' | rados -p testpool put probe -")
        assert pve2.succeed("rados -p testpool get probe -") == "Ceph cluster test"

    with subtest("Recover the OSD and read the object after reboot"):
        pve3.shutdown()
        wait_for_osds(up=2)
        assert pve2.succeed("rados -p testpool get probe -") == "Ceph cluster test"

        pve3.start()
        pve3.wait_for_unit("ceph-osd-2.service")
        wait_for_osds()
        wait_for_health()
        assert pve3.succeed("rados -p testpool get probe -") == "Ceph cluster test"
  '';
}
