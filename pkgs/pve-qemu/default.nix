{
  qemu,
  fetchgit,
  fetchurl,
  ...
}:

(
  (qemu.overrideAttrs (old: {
    version = "8.1.5";

    src = fetchurl {
      url = "https://download.qemu.org/qemu-8.1.5.tar.xz";
      hash = "sha256-l2Ox7+xP1JeWtQgNCINRLXDLY4nq1lxmHMNoalIjKJY=";
    };

    patches =
      let
        src_patches = fetchgit {
          url = "https://git.proxmox.com/git/pve-qemu.git";
          rev = "e62423e6156b7bf9afd8b670722c66c93fd2ba45";
          hash = "sha256-jLFc43HHnOGRXDRyMlmcQ5Fg/Wgc3CbgwSh/TgAPDWQ=";
          fetchSubmodules = false;
        };
        patchesDir = "${src_patches}/debian/patches";
      in
      [ (builtins.head old.patches) ]
      ++ map (e: "${patchesDir}/extra/${e}") (
        builtins.attrNames (builtins.readDir "${patchesDir}/extra/")
      )
      ++ map (e: "${patchesDir}/pve/${e}") (builtins.attrNames (builtins.readDir "${patchesDir}/pve/"))
      ++ map (e: "${patchesDir}/bitmap-mirror/${e}") (
        builtins.attrNames (builtins.readDir "${patchesDir}/bitmap-mirror/")
      );
  })).override
  { glusterfsSupport = true; }
)
