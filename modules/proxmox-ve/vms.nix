{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.proxmox-ve;

  # Fix toString to return "0" for false
  toString' = x: if isBool x && (!x) then "0" else toString x;
  filterAttrsNonEmpty = filterAttrsRecursive (
    _: v:
    v != null
    && (!(isList v) || any (x: x != null) v)
    && (!(isAttrs v) || any (x: x != null) (attrValues v))
  );

  configToParams =
    config:
    processTopLevelAttrs (
      mapAttrs (
        name: value:
        if isAttrs value then
          processAttrs value
        else if isList value then
          (if all isAttrs value then processListOfAttrs name value else processList value)
        else
          toString' value
      ) (filterAttrsNonEmpty config)
    );

  processAttrs =
    attrs:
    concatStringsSep "," (
      mapAttrsToList (
        name: value: "${name}=${if isList value then concatStringsSep ";" value else toString' value}"
      ) (filterAttrsNonEmpty attrs)
    );
  processListOfAttrs = name: l: imap0 (i: x: "-${name}${toString' i} ${processAttrs x}") l;
  processList = concatStringsSep ",";
  processTopLevelAttrs =
    attrs:
    toString' (
      mapAttrsToList (
        name: value: if isString value then "-${name} ${value}" else concatStringsSep " " value
      ) attrs
    );
in

{
  options.services.proxmox-ve.vms = mkOption {
    type = types.attrsOf (
      types.submodule { inherit (import ../declarative-vms/options.nix { inherit config lib; }) options; }
    );
    default = { };
    example = literalExpression ''
      {
        myvm1 = {
          vmid = 100;
          memory = 4096;
          cores = 4;
          sockets = 2;
          kvm = false;
          net = [
            {
              model = "virtio";
              bridge = "vmbr0";
            }
          ];
          scsi = [ { file = "local:16"; } ];
        };
        myvm2 = {
          vmid = 101;
          memory = 8192;
          cores = 2;
          sockets = 2;
          scsi = [ { file = "local:32"; } ];
        };
      };
    '';
    description = "Declarative configuration of Proxmox VMs.";
  };

  config = mkIf cfg.enable {
    systemd.services = mapAttrs' (
      name: conf:
      let
        vmid = toString conf.vmid;
      in
      nameValuePair "pve-generate-vm-${vmid}" {
        description = "PVE VM ${vmid} creation from configuration.";
        wants = [ "pveproxy.service" ];
        after = [ "pveproxy.service" ];
        wantedBy = [ "multi-user.target" ];
        script = ''
          if ${pkgs.proxmox-ve}/bin/pvesh get /cluster/resources --type vm --output-format json | ${pkgs.jq}/bin/jq -r '.[].vmid' | grep -qw "${vmid}"; then
            echo "VM ID ${vmid} is already in use. Skipping creation."
          else
            echo "VM ID ${vmid} is available. Creating the VM..."
            ${pkgs.proxmox-ve}/bin/pvesh create /nodes/${config.networking.hostName}/qemu -name ${name} ${configToParams conf}
            echo "VM ID ${vmid} has been successfully created."
          fi
        '';
      }
    ) cfg.vms;
  };
}
