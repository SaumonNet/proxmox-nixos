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
    version = "9.1.2";

    src = fetchurl {
      url = "https://download.qemu.org/qemu-${version}.tar.xz";
      hash = "sha256-Gf2ddTWlTW4EThhkAqo7OxvfqHw5LsiISFVZLIUQyW8=";
    };

    src_patches = fetchgit {
      url = "git://git.proxmox.com/git/pve-qemu.git";
      rev = "c4efa30b307fc15df5c00f353494d1aec1702680";
      hash = "sha256-EjeB1TLaPIhBQH8KpaQ1PDo453LtMumdNfSf5T4yo/I=";
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
