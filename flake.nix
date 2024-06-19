{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    unstable.url = "nixpkgs/nixos-unstable";
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    crane.url = "github:ipetkov/crane/v0.17.3";
  };

  description = "Proxmox on NixOS";

  outputs =
    {
      self,
      nixpkgs,
      unstable,
      utils,
      crane,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlays."x86_64-linux" ];
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ ];
      };
    in
    {
      nixosModules = import ./modules;

      machines =
        let
          tld = "saumon";
        in
        {
          proxmox-dev = rec {
            inherit tld;
            ipv4 = {
              local = "192.168.0.216";
              vpn = "100.100.45.19";
            };
            deployment.targetHost = ipv4.vpn;
          };
        };

      nixosConfigurations.proxmox-dev = lib.nixosSystem {
        system = "x86_64-linux";
        extraModules = lib.attrValues self.nixosModules;
        inherit pkgs lib;
        modules = [
          (
            { config, ... }:
            {
              networking = {
                hostName = "proxmox-dev";

                useNetworkd = true;

                firewall.allowedTCPPorts = [
                  80
                  443
                  5900
                  5901
                  5902
                ];
                firewall.allowedUDPPorts = [
                  80
                  443
                  5900
                  5901
                  5902
                ];
                nftables.enable = true;
              };
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

              boot.specialFileSystems."/dev/pts" = {
                fsType = "devpts";
                options = [
                  "nosuid"
                  "noexec"
                  "mode=620"
                  "ptmxmode=0000"
                  "gid=${toString config.ids.gids.tty}"
                ];
              };
              imports = [ ./hardware-configuration.nix ];

              services.proxmox-ve = {
                enable = true;
                localIP = self.machines.proxmox-dev.ipv4.local;
              };

              services.proxmox-backup.enable = true;

              security.pam.services."proxmox-ve-auth" = {
                logFailures = true;
                nodelay = true;
              };

              services.tailscale.enable = true;
              services.openssh.enable = true;

              nix.buildMachines = [
                {
                  hostName = "epyc.infra.newtype.fr";
                  system = "x86_64-linux";
                  maxJobs = 10;
                  speedFactor = 2;
                  supportedFeatures = [
                    "nixos-test"
                    "benchmark"
                    "big-parallel"
                    "kvm"
                  ];
                  mandatoryFeatures = [ ];
                }
              ];
              nix.distributedBuilds = true;
              nix.extraOptions = ''
                builders-use-substitutes = true
              '';

              users.users.root.openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmuMNGkWQ7ozpC2UU0+jqMsRw1zVgT2Q9ORmLcTXpK2 camille@zeppelin"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg9kUL5kFcPOWmGy/7kJZMlG2+Ls79XiWgvO8p+OQ3f camille@genesis"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDMBW7rTtfZL9wtrpCVgariKdpN60/VeAzXkh9w3MwbO julien@enigma"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGa+7n7kNzb86pTqaMn554KiPrkHRGeTJ0asY1NjSbpr julien@tower"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIADCpuBL/kSZShtXD6p/Nq9ok4w1DnlSoxToYgdOvUqo julien@telecom"
              ];

              system.stateVersion = "23.11";
            }
          )
        ];
      };

      colmena =
        {
          meta = {
            nixpkgs = pkgs;
            nodeNixpkgs = builtins.mapAttrs (_: v: v.pkgs) self.nixosConfigurations;
            nodeSpecialArgs = builtins.mapAttrs (_: v: v._module.specialArgs) self.nixosConfigurations;
            specialArgs.lib = lib;
          };
        }
        // builtins.mapAttrs (n: v: {
          imports = v._module.args.modules ++ v._module.args.extraModules;
          deployment = self.machines.${n}.deployment // {
            buildOnTarget = lib.mkDefault true;
          };
        }) self.nixosConfigurations;

      checks = self.packages;
    }
    //
      utils.lib.eachSystem
        [
          "x86_64-linux"
          "aarch64-linux"
        ]
        (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ self.overlays.${system} ];
            };
            craneLib = crane.mkLib pkgs;
          in
          {
            overlays =
              _: prev:
              {
                inherit lib;
                unstable = unstable.legacyPackages.${system};
              }
              // (import ./pkgs {
                inherit craneLib;
                pkgs = prev;
              });

            packages = utils.lib.filterPackages system (import ./pkgs { inherit pkgs craneLib; });

            devShells.default = pkgs.mkShell {
              buildInputs = with pkgs; [
                age
                sops
                colmena
                nixos-generators
              ];
            };
          }
        );
}
