{
  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-libvncserver.url = "github:NixOS/nixpkgs/e6f23dc08d3624daab7094b701aa3954923c6bbb";
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
          "riscv64-linux"
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
                (_: _: {
                  inherit
                    (import nixpkgs-libvncserver (
                      {
                        inherit system;
                      }
                      // nixpkgs-stable.lib.optionalAttrs (system == "riscv64-linux") {
                        overlays = [
                          (_: p: {
                            git = p.git.overrideAttrs (_: {
                              doInstallCheck = false;
                            });
                          })
                        ];
                      }
                    ))
                    libvncserver
                    ;
                })
                # https://github.com/NixOS/nixpkgs/pull/557465
                (final: prev: {
                  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
                    (pyfinal: pyprev: {
                      sh = pyprev.sh.overridePythonAttrs (old: {
                        disabledTests = (old.disabledTests or [ ]) ++ [
                          "test_done_callback_no_deadlock"
                          "test_timeout_overstep"
                        ];
                      });
                    })
                  ];

                  binaryen = prev.binaryen.overrideAttrs (
                    old:
                    nixpkgs-stable.lib.optionalAttrs (system == "riscv64-linux") {
                      doCheck = false;
                    }
                  );
                })
              ];
            };
          in
          {
            overlays = _: _: (import ./pkgs { inherit pkgs; });

            packages = utils.lib.filterPackages system (import ./pkgs { inherit pkgs; });

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
