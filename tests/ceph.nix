{
  name = "pve-ceph";

  nodes = {
    pve1 =
      { pkgs, ... }:
      {
        services.proxmox-ve = {
          enable = true;
          ipAddress = "192.168.1.1";
          ceph = {
            enable = true;
            mgr.enable = true;
            mon.enable = true;
            osd = {
              enable = true;
              daemons = [ "1" ];
            };
          };
        };

        environment.systemPackages = [ pkgs.openssl ];

        users.users.root = {
          password = "mypassword";
          initialPassword = null;
          hashedPassword = null;
          hashedPasswordFile = null;
        };

        virtualisation = {
          emptyDiskImages = [ 1024 ];
          memorySize = 2048;
        };
      };

    pve2 = {
      services.proxmox-ve = {
        enable = true;
        ipAddress = "192.168.1.2";
        ceph = {
          enable = true;
          mon.enable = true;
          osd = {
            enable = true;
            daemons = [ "2" ];
          };
        };
      };

      virtualisation = {
        emptyDiskImages = [ 1024 ];
        memorySize = 2048;
      };
    };

    pve3 = {
      services.proxmox-ve = {
        enable = true;
        ipAddress = "192.168.1.3";
        ceph = {
          enable = true;
          mon.enable = true;
          osd = {
            enable = true;
            daemons = [ "3" ];
          };
        };
      };

      virtualisation = {
        emptyDiskImages = [ 1024 ];
        memorySize = 2048;
      };
    };
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

    pve3.wait_for_unit("multi-user.target")
    time.sleep(10)
    pve3.succeed(f"pvesh create /cluster/config/join --hostname 192.168.1.1 --fingerprint {fingerprint.strip()} --password 'mypassword'")

    assert "pve2" in pve1.succeed("pvecm nodes")
    assert "pve3" in pve1.succeed("pvecm nodes")
    assert "Yes" in pve1.succeed("pvecm status | grep Quorate")

    pve1.succeed(
      "pveceph init",
      "pveceph mgr create",
      "pveceph mon create",
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

    pve1.wait_for_unit("ceph.target")
    pve2.wait_for_unit("ceph.target")
    pve3.wait_for_unit("ceph.target")

    time.sleep(10)
    assert "HEALTH_OK" in pve1.succeed("ceph status")
  '';
}
