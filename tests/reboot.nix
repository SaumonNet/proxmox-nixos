{ minimalIso, ... }:

{
  name = "pve-reboot";

  nodes.mypve = {
    services.proxmox-ve = {
      enable = true;
      ipAddress = "192.168.1.1";
      bridges = [ "vmbr0" ];
    };

    networking.bridges.vmbr0.interfaces = [ ];

    virtualisation = {
      additionalPaths = [ minimalIso ];
      diskSize = 4096;
      memorySize = 2048;
    };
  };

  testScript = ''
    mypve.start()
    mypve.wait_for_unit("pveproxy.service")
    mypve.wait_for_unit("qmeventd.service")
    assert "running" in mypve.succeed("pveproxy status")

    mypve.succeed("mkdir -p /var/lib/vz/template/iso/")
    mypve.succeed("cp ${minimalIso} /var/lib/vz/template/iso/minimal.iso")

    mypve.wait_until_succeeds("ip link show vmbr0")

    mypve.succeed(
      "qm create 200 --memory 512 --cores 1 --net0 virtio,bridge=vmbr0 -cdrom local:iso/minimal.iso",
      "qm start 200"
    )
    mypve.wait_until_succeeds("qm status 200 | grep -F 'status: running'")

    mypve.succeed("touch /run/qemu-server/200.reboot")
    mypve.succeed("kill -TERM $(cat /run/qemu-server/200.pid)")

    mypve.wait_until_succeeds(
      "journalctl -u qmeventd.service -b --no-pager | grep -F 'Restarting VM 200'"
    )
    mypve.wait_until_succeeds("qm status 200 | grep -F 'status: running'")
  '';
}
