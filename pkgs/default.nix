{
  pkgs,
  pkgs-unstable,
  craneLib ? { },
  ...
}:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // ours);

  ours = {
    inherit craneLib;

    authenpam = callPackage ./perl-modules/authenpam { };
    datadumper = callPackage ./perl-modules/datadumper { };
    digestsha = callPackage ./perl-modules/digest-sha { };
    findbin = callPackage ./perl-modules/find-bin { };
    iosocketip = callPackage ./perl-modules/iosocketip { };
    mimebase32 = callPackage ./perl-modules/mimebase32 { };
    mimebase64 = callPackage ./perl-modules/mimebase64 { };
    posixstrptime = callPackage ./perl-modules/posixstrptime { };
    socket = callPackage ./perl-modules/socket { };
    termreadline = callPackage ./perl-modules/termreadline { };
    testharness = callPackage ./perl-modules/testharness { };
    uuid = callPackage ./perl-modules/uuid { };

    extjs = callPackage ./extjs { };
    fonts-font-logos = callPackage ./fonts-font-logos { };
    markedjs = callPackage ./markedjs { };
    perlmod = callPackage ./perlmod { };
    termproxy = callPackage ./termproxy { };
    unifont_hex = callPackage ./unifont { };
    vncterm = callPackage ./vncterm { };

    proxmox-acme = callPackage ./proxmox-acme { };
    proxmox-backup = callPackage ./proxmox-backup { };
    proxmox-backup-qemu = callPackage ./proxmox-backup-qemu { };
    proxmox-ve = callPackage ./proxmox-ve { };
    proxmox-widget-toolkit = callPackage ./proxmox-widget-toolkit { };

    pve-access-control = callPackage ./pve-access-control { };
    pve-apiclient = callPackage ./pve-apiclient { };
    pve-cluster = callPackage ./pve-cluster { };
    pve-common = callPackage ./pve-common { };
    pve-container = callPackage ./pve-container { };
    pve-docs = callPackage ./pve-docs { };
    pve-edk2-firmware = callPackage ./pve-edk2-firmware { };
    pve-firewall = callPackage ./pve-firewall { };
    pve-guest-common = callPackage ./pve-guest-common { };
    pve-ha-manager = callPackage ./pve-ha-manager { };
    pve-http-server = callPackage ./pve-http-server { };
    pve-manager = callPackage ./pve-manager { };
    pve-novnc = callPackage ./pve-novnc { };
    pve-qemu = callPackage ./pve-qemu { };
    pve-qemu-server = callPackage ./pve-qemu-server { };
    pve-rados2 = callPackage ./pve-rados2 { };
    pve-rs = callPackage ./pve-rs { };
    pve-storage = callPackage ./pve-storage { };
    pve-xtermjs = callPackage ./pve-xtermjs { };

    linstor-api-py = callPackage ./linstor-api-py { };
    linstor-client = callPackage ./linstor-client { };
    linstor-proxmox = callPackage ./linstor-proxmox { };
    linstor-server = pkgs-unstable.callPackage ./linstor-server {
      protobuf = pkgs-unstable.protobuf_23;
      jre = pkgs.jdk11_headless;
    };
    nixmoxer = callPackage ./nixmoxer { };
  };
in
ours
