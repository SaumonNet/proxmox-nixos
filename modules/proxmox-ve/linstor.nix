{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.proxmox-ve.linstor;
in

{
  meta.maintainers = with maintainers; [
    julienmalka
    camillemndn
  ];

  options.services.proxmox-ve.linstor.enable = mkEnableOption "Linstor for Proxmox VE";

  config = mkIf cfg.enable {
    services.proxmox-ve.package = pkgs.proxmox-ve.override { enableLinstor = true; };
  };
}
