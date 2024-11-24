{
  config,
  lib,
  ...
}:
let
  cfg = config.services.proxmox-ve.bridges;
in
{
  options.services.proxmox-ve.bridges = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "List of Linux or OVS bridges visible in Proxmox web interface. This option has no effect on OS level network config.";
  };

  config = lib.mkIf (builtins.length cfg > 0) {
    environment.etc."network/interfaces" = {
      mode = "0644";
      text = lib.concatMapStringsSep "\n" (br: ''
        auto ${br}
        iface ${br} inet static
          bridge_ports none
      '') cfg;
    };
  };
}
