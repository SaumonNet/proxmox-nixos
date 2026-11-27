{ pkgs }:

let
  guest = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    system = "x86_64-linux";
    modules = [
      (pkgs.path + "/nixos/modules/virtualisation/disk-image.nix")
      ({ config, lib, ... }: {
        nixpkgs.pkgs = pkgs;
        system.stateVersion = "26.05";
        image = {
          baseName = "guest";
          efiSupport = false;
        };
        boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" ];
        services.qemuGuest.enable = true;
        system.build.image = lib.mkForce (import (pkgs.path + "/nixos/lib/make-disk-image.nix") {
          inherit config lib pkgs;
          inherit (config.virtualisation) diskSize;
          inherit (config.image) baseName format;
          partitionTableType = "legacy";
          copyChannel = false;
        });
      })
    ];
  };
in
"${guest.config.system.build.image}/${guest.config.image.fileName}"
