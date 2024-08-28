with import <nixpkgs> { };
let
  openssh-wrapper = pkgs.python3.pkgs.callPackage ./openssh-wrapper.nix { };
in
mkShell {
  packages = [
    (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.proxmoxer
      python-pkgs.paramiko
      python-pkgs.requests_toolbelt
      openssh-wrapper
    ]))
  ];
}
