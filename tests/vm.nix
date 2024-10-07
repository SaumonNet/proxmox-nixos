{ pkgs, ... }:

{

  name = "pve-vm";

  nodes.mypve = {
    services.proxmox-ve.enable = true;
    environment.systemPackages = [ pkgs.nixos-proxmox-ve-iso ];
    virtualisation.diskSize = 4 * 1024;
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("pveproxy.service")
    assert "running" in machine.succeed("pveproxy status")
    machine.succeed("mkdir -p /var/lib/vz/template/iso/")
    machine.succeed("cp ${pkgs.nixos-proxmox-ve-iso}/iso/*.iso /var/lib/vz/template/iso/nixos-proxmox-ve.iso")

    # Seabios VM creation
    machine.succeed("qm create 100 --kvm 0 --bios seabios -cdrom local:iso/nixos-proxmox-ve.iso")
    machine.succeed("qm start 100")
    machine.succeed("qm stop 100 --timeout 0")

    # Legacy ovmf vm creation
    machine.succeed("qm create 101 --kvm 0 --bios ovmf -cdrom local:iso/nixos-proxmox-ve.iso")
    machine.succeed("qm start 101")
    machine.succeed("qm stop 101 --timeout 0")

    # UEFI ovmf vm creation
    machine.succeed("qm create 102 --kvm 0 --bios ovmf --efidisk0 local:4,efitype=4m -cdrom local:iso/nixos-proxmox-ve.iso")
    machine.succeed("qm start 102")
    machine.succeed("qm stop 102 --timeout 0")

    # UEFI ovmf vm creation with secure boot
    machine.succeed("qm create 103 --kvm 0 --bios ovmf --efidisk0 local:4,efitype=4m,pre-enrolled-keys=1 -cdrom local:iso/nixos-proxmox-ve.iso")
    machine.succeed("qm start 103")
    machine.succeed("qm stop 103 --timeout 0")
  '';
}
