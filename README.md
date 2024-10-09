# Proxmox on NixOS

![Proxmox on NixOS](proxmox-nixos.png)

This project is a port of the [Proxmox Hypervisor](https://www.proxmox.com/) on NixOS.

⚠️ Proxmox-NixOS is still **experimental** and we do not advise running it on production machines. Do it at your own risk and only if you are ready to fix issues by yourself.

## 🚦 Supported features

Proxmox-NixOS has been tested on real hardware with most basic features of Proxmox (booting VMs, user management, etc), more involved setups (clusters, HA, etc) are still under development and testing.

## 🗃️ Cache

Some Proxmox packages have a quite power intensive build process. We make a cache available to download directly the artifacts:

- address: `https://cache.saumon.network/proxmox-nixos`
- public key: `proxmox-nixos:nveXDuVVhFDRFx8Dn19f1WDEaNRJjPrF2CPD2D+m1ys=`

## 🚀 Quick start

### With [`npins`](https://github.com/andir/npins)

Add `proxmox-nixos` as a dependency of your npins project.

```console
$ npins add github SaumonNet proxmox-nixos -b main
[INFO ] Adding 'proxmox-nixos' …
    repository: https://github.com/SaumonNet/proxmox-nixos.git
    branch: main
    revision: ...
    url: https://github.com/saumonnet/proxmox-nixos/archive/$revision.tar.gz
    hash: ...
```

Below is a fragment of a NixOS configuration that enables Proxmox VE.

```nix
# file: configuration.nix
{ pkgs, lib, ... }:
let
    sources = import ./npins;
    proxmox-nixos = import sources.proxmox-nixos;
in
{
  imports = [ proxmox-nixos.nixosModules.proxmox-ve ];
  services.proxmox-ve.enable = true;
  nixpkgs.overlays = [
    proxmox-nixos.overlays.x86_64-linux
  ];
  # The rest of your configuration...
}
```

### With Flakes

Below is a fragment of a NixOS configuration that enables Proxmox VE.

```nix
{
  description = "A flake with Proxmox VE enabled";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
  };

  outputs = { self, nixpkgs, proxmox-nixos, ...}: {
    nixosConfigurations = {
      yourHost = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [

          proxmox-nixos.nixosModules.proxmox-ve

          ({ pkgs, lib, ... }: {
            services.proxmox-ve.enable = true;
            nixpkgs.overlays = [
              proxmox-nixos.overlays.${system}
            ];

            # The rest of your configuration...
          })
        ];
      };
    };
  };
}
```

⚠️ Do not override the `nixpkgs-stable` input of the flake, as the only tested and supported version of Proxmox-NixOS is with the upstream stable NixOS release.

## 🌐 Networking

To get internet in your VMs, you need to add a network device to the VM, connected to a bridge. To get this working, follow this 2 steps:

1. Set the list of bridges in `services.proxmox-ve.bridges` option. This is the list of bridges that will be visible in Proxmox web interface. Note that this option doesn't affect your OS level network config in any way.
2. Configure your networking through NixOS configuration so that the bridge you created in the Proxmox web interface actually exists!

### Example NixOS networking configurations

Any kind of advanced networking configuration is possible through the usual NixOS options, but here are basic examples that can get you started:

#### With `systemd-networkd`

```nix
# Make vmbr0 bridge visible in Proxmox web interface
services.proxmox-ve.bridges = [ "vmbr0" ];

# Actually set up the vmbr0 bridge
systemd.network.networks."10-lan" = {
    matchConfig.Name = [ "ens18" ];
    networkConfig = {
    Bridge = "vmbr0";
    };
};

systemd.network.netdevs."vmbr0" = {
    netdevConfig = {
        Name = "vmbr0";
        Kind = "bridge";
    };
};

systemd.network.networks."10-lan-bridge" = {
    matchConfig.Name = "vmbr0";
    networkConfig = {
    IPv6AcceptRA = true;
    DHCP = "ipv4";
    };
    linkConfig.RequiredForOnline = "routable";
};
```

### With scripted networking

```nix
# Make vmbr0 bridge visible in Proxmox web interface
services.proxmox-ve.bridges = [ "vmbr0" ];

# Actually set up the vmbr0 bridge
networking.bridges.vmbr0.interfaces = [ "ens18" ];
networking.interfaces.vmbr0.useDHCP = lib.mkDefault true;
```

## 🧱 Declarative VMs

### Using the module [`virtualisation.proxmox`](modules/declarative-vms)

_This solution is available even for the admin of a particular VM with only
a restricted API access to the Proxmox Hypervisor._

The utility `nixmoxer` allows one to bootstrap NixOS virtual machines on an
existing Proxmox hypervisor, using the API.

First, configure the virtual machine settings using the options of the NixOS module
`virtualisation.proxmox` of your `nixosConfigurations.myvm`:

```nix
# myvm.nix
{ config, ... }:

{
  imports = [ ./disko.nix ];

  networking.hostName = "myvm";

  virtualisation.proxmox = {
    node = "myproxmoxnode";
    iso = <derivation for your iso>;
    vmid = 101;
    memory = 4096;
    cores = 4;
    sockets = 2;
    net = [
      {
        model = "virtio";
        bridge = "vmbr0";
      }
    ];
    scsi = [ { file = "local:16"; } ]; # This will create a 16GB volume in 'local'
  };

  # The rest of your configuration...
}
```

You can find an exhaustive list of options in [modules/declarative-vms/options.nix](modules/declarative-vms/options.nix),
or in the official [documentation](https://pve.proxmox.com/pve-docs/api-viewer/#/nodes/{node}/qemu) of the Proxmox API.

Then configure the access to the Proxmox API:

```sh
# nixmoxer.conf
host=192.168.0.3
user=root
password=<password>
verify_ssl=0
```

Now you can bootstrap `myvm` using `nixmoxer`:

```console
$ nix run github:SaumonNet/proxmox-nixos#nixmoxer -- [--flake] myvm
```

`nixmoxer` will setup the VM on the Proxmox node and attach the specified iso. Instead of specified an iso, setting `autoInstall = true;` will automatically generate an iso that will automatically install the configuration to the VM being bootstrapped.


⚠️ `nixmoxer` shall only be used for the initial bootstraping of a VM, the NixOS VM can be rebuilt with usual tools like `nixos-rebuild`, `colmena`, etc. Changes to the `virtualisation.proxmox` options after the boostraping have no impact.

### Using the module [`services.proxmox-ve.vms`](modules/proxmox-ve/vms.nix)

_This solution is only available for the admin of a Proxmox Hypervisor on NixOS_.

This configuration will create two VMs on a Proxmox-NixOS Hypervisor. Then you can attach an
iso and configuration your VMs as usual.

```nix
# configuration.nix
{
  services.proxmox-ve = {
    enable = true;
    vms = {
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
  };

  # The rest of your configuration...
}
```

You can find an exhaustive list of options in [modules/declarative-vms/options.nix](modules/declarative-vms/options.nix),
or in the official [documentation](https://pve.proxmox.com/pve-docs/api-viewer/#/nodes/{node}/qemu) of the Proxmox API.

⚠️ The current limitation is that if for instance VM `myvm1` has already been initialised,
subsequent changes to the configuration in `services.proxmox-ve.vms.myvm1` will have no impact.


### Note

Truly declarative configuration of virtual machines is very difficult with Proxmox-NixOS because there is essentially 2 sources of truth (the NixOS configuration and the Proxmox web interface) that have to be reconciliated. If you want truly declarative VMs configurations we recommend the amazing project [microvms.nix](https://github.com/astro/microvm.nix).

## 🚧 Roadmap

- Support for clusters / HA with Ceph
- More coverage of NixOS tests
- Proxmox backup server

## 🔧 Maintainance

Most packages are regularly and automatically updated thanks to [a modified version](https://github.com/SaumonNet/proxmox-nixos-update) of the [`nixpkgs-update`](https://github.com/nix-community/nixpkgs-update) bot, whose logs are available [here](https://proxmox-nixos-update-logs.saumon.network/).

## 📬 Help / Discussions

There is [a matrix room](https://matrix.to/#/#proxmox-nixos:matrix.org) for discussions about Proxmox-NixOS.

## Thanks

This project has received support from [NLNet](https://nlnet.nl/).

<pre><img alt="Logo of NLnet Foundation" src="https://nlnet.nl/logo/banner.svg" width="320px" height="120px" />     <img alt="Logo of NGI Assure" src="https://nlnet.nl/image/logos/NGIAssure_tag.svg" width="320px" height="120px" /></pre>
