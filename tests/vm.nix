{ minimalIso, ... }:

{
  name = "pve-vm";

  nodes.mypve = {
    services.proxmox-ve = {
      enable = true;
      ipAddress = "192.168.1.1";

      vms = {
        myvm1 = {
          vmid = 100;
          memory = 1024;
          cores = 1;
          sockets = 1;
          kvm = true;
          scsi = [ { file = "local:16"; } ];
          cdrom = "local:iso/minimal.iso";
        };
      };
    };

    virtualisation = {
      additionalPaths = [ minimalIso ];
      diskSize = 4096;
      memorySize = 2048;
    };
  };

  testScript = ''
    mypve.start()
    mypve.wait_for_unit("pveproxy.service")
    assert "running" in mypve.succeed("pveproxy status")

    # Copy Iso
    mypve.succeed("mkdir -p /var/lib/vz/template/iso/")
    mypve.succeed("cp ${minimalIso} /var/lib/vz/template/iso/minimal.iso")

    # Declarative VM creation
    mypve.wait_for_unit("multi-user.target")
    mypve.succeed("qm stop 100 --timeout 0")

    # Seabios VM creation
    mypve.succeed(
      "qm create 101 --kvm 0 --bios seabios -cdrom local:iso/minimal.iso",
      "qm start 101",
      "qm stop 101 --timeout 0"
    )

    # Legacy ovmf vm creation
    mypve.succeed(
      "qm create 102 --kvm 0 --bios ovmf -cdrom local:iso/minimal.iso",
      "qm start 102",
      "qm stop 102 --timeout 0"
    )

    # UEFI ovmf vm creation
    mypve.succeed(
      "qm create 103 --kvm 0 --bios ovmf --efidisk0 local:4,efitype=4m -cdrom local:iso/minimal.iso",
      "qm start 103",
      "qm stop 103 --timeout 0"
    )

    # UEFI ovmf vm creation with secure boot
    mypve.succeed(
      "qm create 104 --kvm 0 --bios ovmf --efidisk0 local:4,efitype=4m,pre-enrolled-keys=1 -cdrom local:iso/minimal.iso",
      "qm start 104",
      "qm stop 104 --timeout 0"
    )
  '';
}
