{
  pkgs,
  craneLib ? { },
  ...
}:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // ours);
  ours = {
    inherit craneLib;
    authenpam = callPackage ./authenpam { };
    datadumper = callPackage ./authenpam { };
    digestsha = callPackage ./digest-sha { };
    findbin = callPackage ./find-bin { };
    iosocketip = callPackage ./iosocketip { };
    markedjs = callPackage ./markedjs { };
    mimebase32 = callPackage ./mimebase32 { };
    mimebase64 = callPackage ./mimebase64 { };
    perlmod = callPackage ./perlmod { };
    posixstrptime = callPackage ./posixstrptime { };
    proxmox-acme = callPackage ./proxmox-acme { };
    # proxmox-rs = callPackage ./proxmox-rs { };
    proxmox-ve = callPackage ./proxmox-ve { };
    proxmox-widget-toolkit = callPackage ./proxmox-widget-toolkit { };
    pve-access-control = callPackage ./pve-access-control { };
    pve-apiclient = callPackage ./pve-apiclient { };
    pve-cluster = callPackage ./pve-cluster { };
    pve-common = callPackage ./pve-common { };
    pve-container = callPackage ./pve-container { };
    pve-docs = callPackage ./pve-docs { };
    pve-firewall = callPackage ./pve-firewall { };
    pve-guest-common = callPackage ./pve-guest-common { };
    pve-ha-manager = callPackage ./pve-ha-manager { };
    pve-http-server = callPackage ./pve-http-server { };
    pve-manager = callPackage ./pve-manager { };
    pve-novnc = callPackage ./novnc { };
    pve-qemu = callPackage ./pve-qemu { };
    pve-qemu-server = callPackage ./pve-qemu-server { };
    pve-rados2 = callPackage ./pve-rados2 { };
    pve-rs = callPackage ./pve-rs { };
    pve-storage = callPackage ./pve-storage { };
    pve-xtermjs = callPackage ./pve-xtermjs { };
    socket = callPackage ./socket { };
    termproxy = callPackage ./termproxy { };
    termreadline = callPackage ./termreadline { };
    testharness = callPackage ./testharness { };
    uuid = callPackage ./uuid { };
    proxmox-backup = callPackage ./proxmox-backup { };
    proxmox-backup-qemu = callPackage ./proxmox-backup-qemu { };
  };
in
ours
