installBuild:
{
  config,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    "${modulesPath}/profiles/base.nix"
    "${modulesPath}/profiles/installation-device.nix"
  ];

  boot.kernelModules = [ "kvm-intel" ];

  environment.systemPackages = with pkgs; [
    git
    parted # check if this can be removed
    bottom
  ];

  systemd.services.sshd.enable = true;

  isoImage.compressImage = false;
  isoImage.isoBaseName = "nixos-offline-installer";
  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.volumeID = "NIXOS_ISO";
  isoImage.storeContents = [ installBuild.toplevel ];

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  systemd.services.installer = {
    description = "Unattended NixOS installer";
    wantedBy = [ "multi-user.target" ];
    after = [
      "getty.target"
      "nscd.service"
    ];
    conflicts = [ "getty@tty1.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      StandardInput = "tty-force";
      StandardOutput = "inherit";
      StandardError = "inherit";
      TTYReset = "yes";
      TTYVHangup = "yes";
    };
    path = [ "/run/current-system/sw" ];
    environment = config.nix.envVars // {
      inherit (config.environment.sessionVariables) NIX_PATH;
      HOME = "/root";
    };
    script = ''
      set -euxo pipefail

      # If the partitions exist already as-is, parted might error out
      # telling that it can't communicate changes to the kernel...
      wipefs -fa /dev/sda

      # These are the exact steps from
      # https://nixos.org/nixos/manual/index.html#sec-installation-summary
      # needed to add a few -s (parted) and -F (mkfs.ext4) etc. flags to
      # supress prompts
      parted -s /dev/sda -- mklabel gpt
      parted -s /dev/sda -- mkpart primary 512MiB -8GiB
      parted -s /dev/sda -- mkpart primary linux-swap -8GiB 100%
      parted -s /dev/sda -- mkpart ESP fat32 1MiB 512MiB
      parted -s /dev/sda -- set 3 boot on

      mkfs.ext4 -F -L nixos /dev/sda1
      mkswap -L swap /dev/sda2
      swapon /dev/sda2
      echo "y" | mkfs.fat -F 32 -n boot /dev/sda3

      # Labels do not appear immediately, so wait a moment
      sleep 5

      mount /dev/disk/by-label/nixos /mnt
      mkdir -p /mnt/boot
      mount /dev/disk/by-label/boot /mnt/boot

      # nixos-install will run "nix build --store /mnt ..." which won't be able
      # to see what we have in the installer nix store, so copy everything
      # needed over.
      nix copy --no-check-sigs --to local?root=/mnt ${installBuild.toplevel}
      ${installBuild.nixos-install}/bin/nixos-install --no-root-passwd

      reboot
    '';
  };
}
