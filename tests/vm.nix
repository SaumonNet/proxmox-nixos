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
    machine.succeed("qm create 100 --kvm 0 -cdrom local:iso/nixos-proxmox-ve.iso")
    machine.succeed("qm start 100")
  '';
}
