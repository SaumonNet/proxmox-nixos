{ pkgs, ... }:

rec {
  markedjs = pkgs.callPackage ./markedjs.nix { };
  proxmox-ve = pkgs.callPackage ./pve { inherit pve-access-control pve-cluster pve-container pve-firewall pve-ha-manager pve-manager pve-qemu-server pve-storage; };
  pve-novnc = pkgs.callPackage ./novnc { };
  proxmox-widget-toolkit = pkgs.callPackage ./widget-toolkit.nix { };
  perlmod = pkgs.callPackage ./perlmod { };
  pve-access-control = pkgs.callPackage ./pve/access-control.nix { };
  pve-acme = pkgs.callPackage ./pve/acme.nix { };
  pve-apiclient = pkgs.callPackage ./pve/apiclient.nix { };
  pve-cluster = pkgs.callPackage ./pve/cluster.nix { };
  pve-common = pkgs.callPackage ./pve/common.nix { };
  pve-container = pkgs.callPackage ./pve/container.nix { };
  pve-docs = pkgs.callPackage ./pve/docs.nix { };
  pve-firewall = pkgs.callPackage ./pve/firewall.nix { };
  pve-ha-manager = pkgs.callPackage ./pve/ha-manager.nix { inherit pve-qemu pve-qemu-server pve-storage; };
  pve-http-server = pkgs.callPackage ./pve/http-server.nix { };
  pve-guest-common = pkgs.callPackage ./pve/guest-common.nix { };
  pve-manager = pkgs.callPackage ./pve/manager.nix { inherit pve-novnc pve-qemu pve-ha-manager; };
  pve-storage = pkgs.callPackage ./pve/storage.nix { inherit pve-qemu; };
  pve-rados2 = pkgs.callPackage ./pve/rados2.nix { };
  pve-rs = pkgs.callPackage ./pve/rs { };
  pve-qemu-server = pkgs.callPackage ./pve/qemu-server.nix { inherit pve-qemu; };
  pve-qemu = (pkgs.qemu.overrideAttrs (old: {
    inherit (old) patches;
  })).override { glusterfsSupport = true; };
}
