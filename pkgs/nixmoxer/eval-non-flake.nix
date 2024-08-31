let
  conf = import "placeholder_config";
  isoConfig = import ./iso.nix;
  toplevel = conf.nixosConfigurations.vm-dev.config.system.build;
in

(import "${conf.nixosConfigurations.vm-dev.pkgs.path}/nixos/lib/eval-config.nix" {
  system = "x86_64-linux";
  modules = [ (isoConfig toplevel) ];
}).config.system.build.isoImage
