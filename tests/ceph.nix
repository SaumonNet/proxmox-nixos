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
    import time
    start_all()

    pve1.wait_for_unit("pveproxy.service")
    pve1.wait_for_unit("sshd.service")
    pve2.wait_for_unit("sshd.service")
    pve3.wait_for_unit("sshd.service")

    assert "running" in pve1.succeed("pveproxy status")
    assert "Proxmox" in pve1.succeed("curl -k https://localhost:8006")

    pve1.succeed("pvecm create mycluster")
    pve1.wait_for_unit("corosync.service")

    fingerprint = pve1.succeed("openssl x509 -noout -fingerprint -sha256 -in /etc/pve/local/pve-ssl.pem | cut -d= -f2")

    pve2.wait_for_unit("multi-user.target")
    time.sleep(10)
    pve2.succeed(f"pvesh create /cluster/config/join --hostname 192.168.1.1 --fingerprint {fingerprint.strip()} --password 'mypassword'")

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
