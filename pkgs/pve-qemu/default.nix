{
  qemu,
  fetchgit,
  fetchurl,
  proxmox-backup-qemu,
  perl538,
  pkg-config,
}:

(
  (qemu.overrideAttrs (old: rec {
    version = "8.1.5";

    src = fetchurl {
      url = "https://download.qemu.org/qemu-${version}.tar.xz";
      hash = "sha256-l2Ox7+xP1JeWtQgNCINRLXDLY4nq1lxmHMNoalIjKJY=";
    };

    src_patches = fetchgit {
      url = "git://git.proxmox.com/git/pve-qemu.git";
      rev = "e62423e6156b7bf9afd8b670722c66c93fd2ba45";
      hash = "sha256-jLFc43HHnOGRXDRyMlmcQ5Fg/Wgc3CbgwSh/TgAPDWQ=";
      fetchSubmodules = false;
    };

    patches =
      let
        series = builtins.readFile "${src_patches}/debian/patches/series";
        patchList = builtins.filter (patch: builtins.isString patch && patch != "") (
          builtins.split "\n" series
        );
        patchPathsList = map (patch: "${src_patches}/debian/patches/${patch}") patchList;
      in
      old.patches ++ patchPathsList;

    buildInputs = old.buildInputs ++ [ proxmox-backup-qemu ];
    propagatedBuildInputs = [ proxmox-backup-qemu ];

    preBuild =
      ''
        cp ${proxmox-backup-qemu}/lib/proxmox-backup-qemu.h .
      ''
      + old.preBuild;

    nativeBuildInputs = old.nativeBuildInputs ++ [
      proxmox-backup-qemu
      perl538
      pkg-config
    ];
  })).override
  {
    glusterfsSupport = true;
    enableDocs = false;
  }
)
