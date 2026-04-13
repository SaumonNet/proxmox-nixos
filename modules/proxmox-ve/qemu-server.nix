{
  config,
  lib,
  pkgs,
  ...
}:

let
  pveDbusVmstate = pkgs.runCommand "pve-dbus-vmstate" { } ''
    mkdir -p $out/lib/systemd/system $out/share/dbus-1/system.d
    cp ${pkgs.pve-qemu-server}/lib/systemd/system/pve-dbus-vmstate@.service \
      $out/lib/systemd/system/
    cp ${pkgs.pve-qemu-server}/share/dbus-1/system.d/org.qemu.VMState1.conf \
      $out/share/dbus-1/system.d/
  '';
in
lib.mkIf config.services.proxmox-ve.enable {
  # Mirror upstream qemu-server's debian/tmpfiles. /run/qemu-server/efidisk
  # is required by `qm start` for OVMF VMs without an explicit efidisk0
  # since qemu-server 9.1.10 (commit c7e62814) moved the temporary EFI disk
  # to /run.
  systemd.tmpfiles.rules = [
    "d /run/qemu-server         0750 root www-data -"
    "d /run/qemu-server/efidisk 0750 root www-data -"
  ];

  systemd.packages = [ pveDbusVmstate ];
  services.dbus.packages = [ pveDbusVmstate ];

  systemd.services.qmeventd = {
    description = "PVE Qemu Event Daemon";
    unitConfig.RequiresMountsFor = [ "/var/run" ];
    wantedBy = [ "multi-user.target" ];
    before = [
      "pve-ha-lrm.service"
      "pve-guests.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.pve-ha-manager}/bin/qmeventd /var/run/qmeventd.sock";
      Type = "forking";
    };
  };
}
