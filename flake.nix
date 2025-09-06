{
  inputs = {
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  nixConfig.extra-substituters = "https://cache.saumon.network/proxmox-nixos";
  nixConfig.extra-trusted-public-keys = "proxmox-nixos:D9RYSWpQQC/msZUWphOY2I5RLH5Dd6yQcaHIuug7dWM=";

  description = "Proxmox on NixOS";

  outputs =
    {
      self,
      nixpkgs-stable,
      nixpkgs-unstable,
      pre-commit-hooks,
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
            pre-commit-check = pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                deadnix.enable = true;
                nixfmt-rfc-style.enable = true;
              };
            };
          in
          {
            overlays = _: _: (import ./pkgs { inherit pkgs pkgs-unstable; });

            packages = utils.lib.filterPackages system (import ./pkgs { inherit pkgs pkgs-unstable; });

            devShells.default = pkgs.mkShell {
              packages = with pkgs; [
                nixfmt-rfc-style
              ];
            };

            checks =
              {
                pre-commit-check = pre-commit-check;
              }
              // (
                if system == "x86_64-linux" then
                  (
                    self.packages.${system}
                    // (import ./tests {
                      inherit pkgs;
                      extraBaseModules = self.nixosModules;
                    })
                  )
                else
                  { }
              );
          }
        );
}
