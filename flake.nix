{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    # Used for qemu
    nixpkgs-stable.url = "nixpkgs/nixos-24.05";
    utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    crane.url = "github:ipetkov/crane/v0.17.3";
  };

  nixConfig.extra-substituters = "https://cache.saumon.network/proxmox-nixos";
  nixConfig.extra-trusted-public-keys = "proxmox-nixos:nveXDuVVhFDRFx8Dn19f1WDEaNRJjPrF2CPD2D+m1ys=";

  description = "Proxmox on NixOS";

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
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
            pkgs-stable = nixpkgs-stable.legacyPackages.${system};
          in
          {
            overlays =
              _: prev:
              (import ./pkgs {
                inherit craneLib pkgs-stable;
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

            packages = utils.lib.filterPackages system (import ./pkgs { inherit pkgs pkgs-stable craneLib; }) // {
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
              if (system == "x86_64-linux") then
                (
                  self.packages.${system}
                  // (import ./tests {
                    inherit pkgs;
                    extraBaseModules = self.nixosModules;
                  })
                )
              else
                { };
          }
        );
}
