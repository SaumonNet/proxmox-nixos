{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    unstable.url = "nixpkgs/nixos-unstable";
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
    in
    {
      nixosModules = import ./modules;
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
              })
              // {
                nixos-proxmox-ve-iso =
                  (lib.nixosSystem {
                    extraModules = lib.attrValues self.nixosModules;
                    pkgs = prev;
                    inherit system;
                    modules = [
                      "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                      (_: {
                        services.proxmox-ve.enable = true;
                        isoImage.isoBaseName = "nixos-proxmox-ve";
                      })
                    ];
                  }).config.system.build.isoImage;
              };

            packages = utils.lib.filterPackages system (import ./pkgs { inherit pkgs craneLib; }) // {
              nixos-proxmox-ve-iso =
                (lib.nixosSystem {
                  extraModules = lib.attrValues self.nixosModules;
                  inherit pkgs system;
                  modules = [
                    "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                    (_: {
                      services.proxmox-ve.enable = true;
                      isoImage.isoBaseName = "nixos-proxmox-ve";
                    })
                  ];
                }).config.system.build.isoImage;
            };

            checks =
              self.packages.${system}
              // (import ./tests {
                inherit pkgs;
                extraBaseModules = self.nixosModules;
              });
          }
        );
}
