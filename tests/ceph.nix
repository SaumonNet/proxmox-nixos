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

  defaults = {
    virtualisation = {
      emptyDiskImages = [ 1024 ];
      memorySize = 2048;
    };
  };

  nodes = {
    pve1 = { pkgs, ... }: {
      imports = [ (node "192.168.1.1" "1") ];
      services.proxmox-ve.ceph.mgr.enable = true;
      environment.systemPackages = [ pkgs.openssl ];
      users.users.root = {
        password = "mypassword";
        initialPassword = null;
        hashedPassword = null;
        hashedPasswordFile = null;
      };
    };
    pve2 = node "192.168.1.2" "2";
    pve3 = node "192.168.1.3" "3";
  };

  testScript = ''
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

    pve1.succeed(
      "pveceph init",
      "pveceph mon create",
      "pveceph mgr create",
      "ceph-volume lvm create --osd-id 1 --data /dev/vdb --no-systemd"
    )

    pve2.succeed(
      "pveceph init",
      "pveceph mon create",
      "ceph-volume lvm create --osd-id 2 --data /dev/vdb --no-systemd"
    )

    pve3.succeed(
      "pveceph init",
      "pveceph mon create",
      "ceph-volume lvm create --osd-id 3 --data /dev/vdb --no-systemd"
    )
  '';
}
