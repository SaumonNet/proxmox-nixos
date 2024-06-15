{ pkgs, ... }:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // ours);
  ours = {
    markedjs = callPackage ./misc/markedjs.nix { };
    perlmod = callPackage ./misc/perlmod { };
    proxmox-acme = callPackage ./acme.nix { };
    proxmox-ve = callPackage ./pve { };
    proxmox-widget-toolkit = callPackage ./widget-toolkit.nix { };
    pve-access-control = callPackage ./pve/access-control.nix { };
    pve-apiclient = callPackage ./pve/apiclient.nix { };
    pve-cluster = callPackage ./pve/cluster.nix { };
    pve-common = callPackage ./pve/common.nix { };
    pve-container = callPackage ./pve/container.nix { };
    pve-docs = callPackage ./pve/docs.nix { };
    pve-firewall = callPackage ./pve/firewall.nix { };
    pve-guest-common = callPackage ./pve/guest-common.nix { };
    pve-ha-manager = callPackage ./pve/ha-manager.nix { };
    pve-http-server = callPackage ./pve/http-server.nix { };
    pve-manager = callPackage ./pve/manager.nix { };
    pve-novnc = callPackage ./misc/novnc { };
    pve-qemu-server = callPackage ./pve/qemu-server.nix { };
    pve-rados2 = callPackage ./pve/rados2.nix { };
    pve-rs = callPackage ./pve/rs { };
    pve-storage = callPackage ./pve/storage.nix { };
    pve-xtermjs = callPackage ./pve/xtermjs.nix { };
    termproxy = callPackage ./rs/termproxy { };
    pve-qemu = callPackage ./pve/qemu.nix { };
    proxmox-rs = callPackage ./rs { };
  };
in
ours
