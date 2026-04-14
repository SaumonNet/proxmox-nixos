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
    machine.start()
    machine.wait_for_unit("pveproxy.service")
    machine.wait_for_unit("qmeventd.service")
    assert "running" in machine.succeed("pveproxy status")

    machine.succeed("mkdir -p /var/lib/vz/template/iso/")
    machine.succeed("cp ${minimalIso} /var/lib/vz/template/iso/minimal.iso")

    machine.wait_until_succeeds("ip link show vmbr0")

    machine.succeed(
      "qm create 200 --memory 512 --cores 1 --net0 virtio,bridge=vmbr0 -cdrom local:iso/minimal.iso",
      "qm start 200"
    )
    machine.wait_until_succeeds("qm status 200 | grep -F 'status: running'")

    machine.succeed("touch /run/qemu-server/200.reboot")
    machine.succeed("kill -TERM $(cat /run/qemu-server/200.pid)")

    machine.wait_until_succeeds(
      "journalctl -u qmeventd.service -b --no-pager | grep -F 'Restarting VM 200'"
    )
    machine.wait_until_succeeds("qm status 200 | grep -F 'status: running'")
  '';
}
