{
  pkgs,
  ...
}:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // ours);

  ours = {
    authenpam = callPackage ./perl-modules/authenpam { };
    datadumper = callPackage ./perl-modules/datadumper { };
    digestsha = callPackage ./perl-modules/digestsha { };
    findbin = callPackage ./perl-modules/findbin { };
    iosocketip = callPackage ./perl-modules/iosocketip { };
    mimebase32 = callPackage ./perl-modules/mimebase32 { };
    mimebase64 = callPackage ./perl-modules/mimebase64 { };
    netsubnet = callPackage ./perl-modules/netsubnet { };
    posixstrptime = callPackage ./perl-modules/posixstrptime { };
    socket = callPackage ./perl-modules/socket { };
    termreadline = callPackage ./perl-modules/termreadline { };
    testharness = callPackage ./perl-modules/testharness { };
    uuid = callPackage ./perl-modules/uuid { };

    extjs = callPackage ./extjs { };
    fonts-font-logos = callPackage ./fonts-font-logos { };
    sencha-touch = callPackage ./sencha-touch { };
    markedjs = callPackage ./markedjs { };
    perlmod = callPackage ./perlmod { };
    termproxy = callPackage ./termproxy { };
    unifont_hex = callPackage ./unifont { };
    vncterm = callPackage ./vncterm { };
    cstream = callPackage ./cstream { };

    mkRegistry = callPackage ./proxmox-registry { };

    proxmox-acme = callPackage ./proxmox-acme { };
    proxmox-backup-qemu = callPackage ./proxmox-backup-qemu { };
    proxmox-i18n = callPackage ./proxmox-i18n { };
    proxmox-ve = callPackage ./proxmox-ve { };
    proxmox-wasm-builder = callPackage ./proxmox-wasm-builder { };
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
    pve-network = callPackage ./pve-network { };
    pve-novnc = callPackage ./pve-novnc { };
    pve-qemu = callPackage ./pve-qemu { };
    pve-qemu-server = callPackage ./pve-qemu-server { };
    pve-rados2 = callPackage ./pve-rados2 { };
    pve-rs = callPackage ./pve-rs { };
    pve-storage = callPackage ./pve-storage { };
    pve-xtermjs = callPackage ./pve-xtermjs { };
    pve-yew-mobile-gui = callPackage ./pve-yew-mobile-gui { };

    linstor-api-py = callPackage ./linstor-api-py { };
    linstor-client = callPackage ./linstor-client { };
    linstor-proxmox = callPackage ./linstor-proxmox { };
    linstor-server = callPackage ./linstor-server {
      jre = pkgs.jdk11_headless;
    };

    nixmoxer = callPackage ./nixmoxer { };
    pve-update = callPackage ./pve-update { };
    pve-update-script = callPackage ./pve-update/pve-update-script.nix { };
  };
in
ours
