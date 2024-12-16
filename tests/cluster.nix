{
  name = "pve-cluster";

  nodes = {
    pve1 =
      { pkgs, ... }:
      {
        services.proxmox-ve = {
          enable = true;
          ipAddress = "192.168.1.1";
        };

        environment.systemPackages = [ pkgs.openssl ];

        users.users.root = {
          password = "mypassword";
          initialPassword = null;
          hashedPassword = null;
          hashedPasswordFile = null;
        };
      };
    pve2 = {
      services.proxmox-ve = {
        enable = true;
        ipAddress = "192.168.1.2";
      };
    };
  };

  testScript = ''
    import time
    pve1.start()
    pve2.start()
    pve1.wait_for_unit("pveproxy.service")
    pve1.wait_for_unit("sshd.service")
    pve2.wait_for_unit("sshd.service")
    assert "running" in pve1.succeed("pveproxy status")
    assert "Proxmox" in pve1.succeed("curl -k https://localhost:8006")

    pve1.succeed("pvecm create mycluster")
    pve1.wait_for_unit("corosync.service")

    fingerprint = pve1.succeed("openssl x509 -noout -fingerprint -sha256 -in /etc/pve/local/pve-ssl.pem | cut -d= -f2")

    pve2.wait_for_unit("multi-user.target")
    time.sleep(10)
    pve2.succeed(f"pvesh create /cluster/config/join --hostname 192.168.1.1 --fingerprint {fingerprint.strip()} --password 'mypassword'")
    pve2.succeed("pvecm status")
  '';
}
