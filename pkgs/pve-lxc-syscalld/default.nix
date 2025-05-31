{
  lib,
  fetchgit,
  pkg-config,
  craneLib,
  systemdLibs
}:

let
  isProxmoxRS = p: lib.hasPrefix "git+https://github.com/proxmox/proxmox-rs.git" p.source;
in
craneLib.buildPackage {
  pname = "pve-lxc-syscalld";
  version = "1.3.0";

  src = fetchgit {
    url = "git://git.proxmox.com/git/pve-lxc-syscalld.git";
    rev = "1a98063bd9a3876cc699bb22fa8c1a1bda02ef3d";
    hash = "sha256-SEFeeJgK0Qw7st9eK1k8g3gJkQ+li5Ucfdj1GWIjj1c=";
  };
  
  postPatch = ''
    rm -rf .cargo
    cp ${./Cargo.lock} Cargo.lock
    cp ${./Cargo.toml} Cargo.toml
  '';

  REPOID = "lol";

  cargoVendorDir = craneLib.vendorCargoDeps {
    cargoLock = ./Cargo.lock;
    overrideVendorGitCheckout =
      ps: drv:
      if (lib.any isProxmoxRS ps) then
        (drv.overrideAttrs (_old: {
          postPatch = ''
            rm .cargo/config 
          '';
        }))
      else
        drv;
  };

  buildInputs = [
    systemdLibs
  ];

  meta = with lib; {
    description = "";
    homepage = "git://git.proxmox.com/?p=proxmox.git";
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    mainProgram = "proxmox";
  };
}
