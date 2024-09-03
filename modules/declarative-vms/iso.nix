installBuild:
{
  config,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];

  boot.kernelModules = [ "kvm-intel" ];

  environment.systemPackages = with pkgs; [ git ];

  isoImage.compressImage = false;
  isoImage.squashfsCompression = null;
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
      ${installBuild.diskoScript}

      # nixos-install will run "nix build --store /mnt ..." which won't be able
      # to see what we have in the installer nix store, so copy everything
      # needed over.
      nix copy --no-check-sigs --to local?root=/mnt ${installBuild.toplevel}
      ${installBuild.nixos-install}/bin/nixos-install --no-channel-copy --no-root-passwd --system ${installBuild.toplevel}

      reboot
    '';
  };
}
