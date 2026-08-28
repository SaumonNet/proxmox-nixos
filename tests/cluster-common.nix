{ lib }:

let
  vmid = 100;

  mkNode =
    ipAddress: extraConfig:
    { pkgs, ... }:
    lib.mkMerge [
      {
        services.proxmox-ve = {
          enable = true;
          inherit ipAddress;
          bridges = [ "vmbr0" ];
        };

        networking.bridges.vmbr0.interfaces = [ ];

        virtualisation.diskSize = 4096;
        virtualisation.memorySize = 2048;

        # Give slower test VMs more time to migrate conntrack state and validate it.
        boot.kernelModules = [
          "nf_conntrack"
          "nf_conntrack_netlink"
        ];
        boot.kernel.sysctl = {
          "net.netfilter.nf_conntrack_udp_timeout" = 300;
          "net.netfilter.nf_conntrack_udp_timeout_stream" = 300;
        };
      }
      (extraConfig pkgs)
    ];
in
{
  inherit vmid;

  nodes = {
    pve1 = mkNode "192.168.1.1" (pkgs: {
      environment.systemPackages = with pkgs; [
        openssl
        conntrack-tools
        netcat-openbsd
      ];

      users.users.root = {
        password = "mypassword";
        initialPassword = null;
        hashedPassword = null;
        hashedPasswordFile = null;
      };
    });

    pve2 = mkNode "192.168.1.2" (pkgs: {
      environment.systemPackages = with pkgs; [
        conntrack-tools
        netcat-openbsd
      ];
    });
  };

  clusterSetupScript = ''
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

    pve2.wait_for_unit("multi-user.target")
    time.sleep(10)

    fingerprint = pve1.succeed("openssl x509 -noout -fingerprint -sha256 -in /etc/pve/local/pve-ssl.pem | cut -d= -f2")
    pve2.succeed(f"pvesh create /cluster/config/join --hostname 192.168.1.1 --fingerprint {fingerprint.strip()} --password 'mypassword'")

    assert "Yes" in pve2.succeed("pvecm status | grep Quorate")
    assert "pve2" in pve1.succeed("pvecm nodes")
  '';

  vmSetupScript = ''
    pve1.succeed(
      "qm create ${toString vmid} --name migrate-me --memory 512 --cores 1 --kvm 0 --net0 virtio,bridge=vmbr0 --scsi0 local:4"
    )
    pve1.succeed("qm start ${toString vmid}")
    pve1.succeed("qm status ${toString vmid} | grep -F running")
  '';

  conntrackSetupScript = ''
    pve2.succeed("sh -c 'nohup nc -u -l 12345 >/tmp/conntrack-listener.log 2>&1 &'")
    pve1.succeed("sh -c 'printf ping | nc -u -p 12346 -w1 192.168.1.2 12345 || true'")
    pve1.succeed(
      "conntrack -U -p udp -s 192.168.1.1 -d 192.168.1.2 --sport 12346 --dport 12345 -m ${toString vmid}"
    )
    pve1.succeed("conntrack -L -o extended -p udp -m ${toString vmid} | grep -F 'mark=${toString vmid}'")
  '';

  conntrackValidationScript = ''
    pve2.wait_until_succeeds(
      "conntrack -L -o extended -p udp -m ${toString vmid} | grep -F 'mark=${toString vmid}'",
      timeout=30,
    )
  '';

  dbusVmstateValidationScript = ''
    pve1.fail("systemctl --quiet is-active pve-dbus-vmstate@${toString vmid}.service")
    pve2.fail("systemctl --quiet is-active pve-dbus-vmstate@${toString vmid}.service")
  '';

  clusterValidationScript = ''
    pve2.succeed("qm status ${toString vmid} | grep -F running")
    pve1.succeed("pvesh get /cluster/resources --type vm --output-format json | grep -F '\"vmid\":${toString vmid}' | grep -F '\"node\":\"pve2\"'")
  '';
}
