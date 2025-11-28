{
  inputs = {
    nixpkgs-stable.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs-libvncserver.url = "nixpkgs/e6f23dc08d3624daab7094b701aa3954923c6bbb";
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
      nixpkgs-libvncserver,
      utils,
      ...
    }:
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
              overlays = [
                self.overlays.${system}
                (_: _: { inherit (nixpkgs-libvncserver.legacyPackages.${system}) libvncserver; })
              ];
            };

            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              overlays = [ ];
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
