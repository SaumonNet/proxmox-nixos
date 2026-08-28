{
  common-updater-scripts,
  lib,
  nix,
  qemu,
  fetchurl,
  fetchgit,
  proxmox-backup-qemu,
  perl5,
  pve-update,
  writeShellScript,
}:

let
  pveSrc = fetchgit {
    url = "git://git.proxmox.com/git/pve-qemu.git";
    rev = "ed7782b2471fc8f3888c3c4c0329d4d124cf38cb";
    hash = "sha256-sP1IeDujfw+DLuP+adNddo4Guy+CVp9tqRgLymTdQnI=";
    fetchSubmodules = false;
  };

  perlDeps = with perl5.pkgs; [ JSON ];
  perlEnv = perl5.withPackages (_: perlDeps);
in
(qemu.overrideAttrs (
  finalAttrs: old:
  let
    qemuVersion = lib.head (lib.splitString "-" finalAttrs.version);
  in
  {
    pname = "pve-qemu";
    version = "10.2.1-2";

    src = fetchurl {
      url = "https://download.qemu.org/qemu-${qemuVersion}.tar.xz";
      hash = "sha256-o3F0d9jiyE1jC//7wg9s0yk+tFqh5trG0MwnaJmRyeE=";
    };

    sourceRoot = "qemu-${qemuVersion}";

    buildInputs = old.buildInputs ++ [ proxmox-backup-qemu ];

    # Applied here to avoid IFD
    postPatch = old.postPatch + ''
      while IFS= read -r pvePatch; do
        [ -n "$pvePatch" ] || continue
        echo "applying $pvePatch"
        patch -p1 < ${pveSrc}/debian/patches/"$pvePatch"
      done < ${pveSrc}/debian/patches/series

      cp ${proxmox-backup-qemu}/lib/proxmox-backup-qemu.h .
    '';

    # Generate cpu flag files and machine versions json
    # This is done in /debian/rules of pve-qemu, and needed by pve-qemu-server
    postInstall = old.postInstall + ''
      $out/bin/qemu-system-x86_64 -cpu help \
        | ${perlEnv}/bin/perl ${pveSrc}/debian/parse-cpu-flags.pl > $out/share/qemu/recognized-CPUID-flags-x86_64
      $out/bin/qemu-system-x86_64 -machine help \
        | ${perlEnv}/bin/perl ${pveSrc}/debian/parse-machines.pl > $out/share/qemu/machine-versions-x86_64.json
    '';

    passthru = (old.passthru or { }) // {
      inherit pveSrc;

      updateScript = writeShellScript "update-pve-qemu" ''
        set -euo pipefail

        attr="''${1:-''${UPDATE_NIX_ATTR_PATH:-pve-qemu}}"

        ${lib.getExe pve-update} \
          --deb-name pve-qemu-kvm \
          --source-key pveSrc \
          "$attr"

        version="$(${nix}/bin/nix eval --raw ".#$attr.version")"
        ${common-updater-scripts}/bin/update-source-version \
          "$attr" \
          "$version" \
          --source-key=src \
          --ignore-same-version
      '';
    };

    meta.position = dirOf ./.;
  }
)).override
  {
    glusterfsSupport = true;
    enableDocs = false;
    cephSupport = true;
  }
