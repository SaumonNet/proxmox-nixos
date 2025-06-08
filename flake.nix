{
  inputs = {
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
  };

  nixConfig.extra-substituters = "https://cache.saumon.network/proxmox-nixos";
  nixConfig.extra-trusted-public-keys = "proxmox-nixos:D9RYSWpQQC/msZUWphOY2I5RLH5Dd6yQcaHIuug7dWM=";

  description = "Proxmox on NixOS";

  outputs =
    {
      self,
      nixpkgs-stable,
      nixpkgs-unstable,
      utils,
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
          in
          {
            overlays = _: _: (import ./pkgs { inherit pkgs pkgs-unstable; });

            packages = utils.lib.filterPackages system (import ./pkgs { inherit pkgs pkgs-unstable; });

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
