{ pkgs, ... }:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // ours);
  ours = rec {
    markedjs = callPackage ./markedjs.nix { };
    proxmox-ve = callPackage ./pve { };
    pve-novnc = callPackage ./novnc { };
    proxmox-widget-toolkit = callPackage ./widget-toolkit.nix { };
    perlmod = callPackage ./perlmod { };
    pve-access-control = callPackage ./pve/access-control.nix { };
    pve-acme = callPackage ./pve/acme.nix { };
    pve-apiclient = callPackage ./pve/apiclient.nix { };
    pve-cluster = callPackage ./pve/cluster.nix { };
    pve-common = callPackage ./pve/common.nix { };
    pve-container = callPackage ./pve/container.nix { };
    pve-docs = callPackage ./pve/docs.nix { };
    pve-firewall = callPackage ./pve/firewall.nix { };
    pve-ha-manager = callPackage ./pve/ha-manager.nix { };
    pve-http-server = callPackage ./pve/http-server.nix { };
    pve-guest-common = callPackage ./pve/guest-common.nix { };
    pve-manager = callPackage ./pve/manager.nix { };
    pve-storage = callPackage ./pve/storage.nix { };
    pve-rados2 = callPackage ./pve/rados2.nix { };
    pve-rs = callPackage ./pve/rs { };
    pve-qemu-server = callPackage ./pve/qemu-server.nix { };
    pve-qemu = (pkgs.qemu.overrideAttrs (old: {
      inherit (old) patches;
    })).override { glusterfsSupport = true; };
  };
in
ours
