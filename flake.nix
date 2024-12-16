{
  inputs = {
    nixpkgs-stable.url = "nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
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
      nixpkgs-stable,
      nixpkgs-unstable,
      utils,
      crane,
      ...
    }:
    let
      inherit (nixpkgs-stable) lib;
    in
    {
      nixosModules = import ./modules;
    }
    //
      utils.lib.eachSystem
        [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ]
        (
          system:
          let
            pkgs = import nixpkgs-stable {
              inherit system;
              overlays = [ self.overlays.${system} ];
            };
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              overlays = [
                (_: prev: {
                  pacemaker = prev.pacemaker.overrideAttrs (_: {
                    env.NIX_CFLAGS_COMPILE = toString (
                      [ "-Wno-error=deprecated-declarations" ]
                      ++ lib.optionals prev.stdenv.cc.isGNU [ "-Wno-error=strict-prototypes" ]
                    );
                  });

                })
              ];
            };
            craneLib = crane.mkLib pkgs;
          in
          {
            overlays = _: _: (import ./pkgs { inherit pkgs pkgs-unstable craneLib; });

            packages = utils.lib.filterPackages system (import ./pkgs { inherit pkgs pkgs-unstable craneLib; });

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
