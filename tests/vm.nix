{ pkgs, ... }:

let
  minimalIso = pkgs.fetchurl {
    url = "https://releases.nixos.org/nixos/24.05/nixos-24.05.7139.bcba2fbf6963/nixos-minimal-24.05.7139.bcba2fbf6963-x86_64-linux.iso";
    hash = "sha256-plre/mIHdIgU4xWU+9xErP+L4i460ZbcKq8iy2n4HT8=";
  };
in

{
  name = "pve-vm";

  nodes.mypve = {
    services.proxmox-ve = {
      enable = true;

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
    machine.start()
    machine.wait_for_unit("pveproxy.service")
    assert "running" in machine.succeed("pveproxy status")

    # Copy Iso
    machine.succeed("mkdir -p /var/lib/vz/template/iso/")
    machine.succeed("cp ${minimalIso} /var/lib/vz/template/iso/minimal.iso")

    # Declarative VM creation
    machine.wait_for_unit("multi-user.target")
    machine.succeed("qm stop 100 --timeout 0")

    # Seabios VM creation
    machine.succeed(
      "qm create 101 --kvm 0 --bios seabios -cdrom local:iso/minimal.iso",
      "qm start 101",
      "qm stop 101 --timeout 0"
    )

    # Legacy ovmf vm creation
    machine.succeed(
      "qm create 102 --kvm 0 --bios ovmf -cdrom local:iso/minimal.iso",
      "qm start 102",
      "qm stop 102 --timeout 0"
    )

    # UEFI ovmf vm creation
    machine.succeed(
      "qm create 103 --kvm 0 --bios ovmf --efidisk0 local:4,efitype=4m -cdrom local:iso/minimal.iso",
      "qm start 103",
      "qm stop 103 --timeout 0"
    )

    # UEFI ovmf vm creation with secure boot
    machine.succeed(
      "qm create 104 --kvm 0 --bios ovmf --efidisk0 local:4,efitype=4m,pre-enrolled-keys=1 -cdrom local:iso/minimal.iso",
      "qm start 104",
      "qm stop 104 --timeout 0"
    )
  '';
}
