{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  util-linux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libfuse";
  version = "2.9.9";

  src = fetchurl {
    url = "https://github.com/libfuse/libfuse/releases/download/fuse-${finalAttrs.version}/fuse-${finalAttrs.version}.tar.gz";
    hash = "sha256-0OadXWCMwi/0hDeRrQl/VU3TJUDdyb7XY4zG/qfBtLU=";
  };

  patches = lib.optional stdenv.hostPlatform.isAarch64 (fetchpatch {
    name = "use-linux-kernel-types.patch";
    url = "https://github.com/libfuse/libfuse/commit/914871b20a901e3e1e981c92bc42b1c93b7ab81b.patch";
    sha256 = "1w4j6f1awjrycycpvmlv0x5v9gprllh4dnbjxl4dyl2jgbkaw6pa";
  });

  # pmxcfs runs as root and mounts /etc/pve directly through libfuse.
  configureFlags = [
    "--disable-util"
    "--disable-example"
  ];

  postPatch = ''
    substituteInPlace lib/Makefile.in \
      --replace-fail '$(bindir)' '/run/wrappers/bin'
    substituteInPlace lib/mount_util.c \
      --replace-fail '/bin/mount' '${lib.getBin util-linux}/bin/mount' \
      --replace-fail '/bin/umount' '${lib.getBin util-linux}/bin/umount'
  '';

  outputs = [ "out" "dev" ];

  meta = {
    description = "FUSE 2 userspace library for pmxcfs";
    homepage = "https://github.com/libfuse/libfuse";
    license = lib.licenses.lgpl21Only;
    platforms = lib.platforms.linux;
  };
})
