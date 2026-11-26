{
  common-updater-scripts,
  lib,
  stdenv,
  nix,
  ceph,
  qemu,
  fetchurl,
  fetchgit,
  libuuid,
  proxmox-backup-qemu,
  systemdLibs,
  perl5,
  pve-update,
  writeShellScript,
}:

let
  pveSrc = fetchgit {
    url = "git://git.proxmox.com/git/pve-qemu.git";
    rev = "242e15da9cbdf3e5b64f0ea9a4719dca99a0f2c3";
    hash = "sha256-othiaAcgPB1J6QyKOjwG4YcYtcMVbZcVRaDMTpPeftY=";
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
    version = "11.1.3-4";

    src = fetchurl {
      url = "https://download.qemu.org/qemu-${qemuVersion}.tar.xz";
      hash = "sha256-WoKJx5QNx304c8gabCm6Ov4URvydNud/oWWM2+y4SyI=";
    };

    sourceRoot = "qemu-${qemuVersion}";

    buildInputs = old.buildInputs ++ [
      libuuid
      proxmox-backup-qemu
      systemdLibs
    ];

    # Applied here to avoid IFD
    postPatch = old.postPatch + ''
      while IFS= read -r pvePatch; do
        [ -n "$pvePatch" ] || continue
        echo "applying $pvePatch"
        patch -p1 < ${pveSrc}/debian/patches/"$pvePatch"
      done < ${pveSrc}/debian/patches/series

      cp ${proxmox-backup-qemu}/lib/proxmox-backup-qemu.h .
    '';

    # qemu-server reads the CPU and machine lists generated in Proxmox's debian/rules.
    postInstall = old.postInstall + ''
      ${perlEnv}/bin/perl ${pveSrc}/debian/parse-cpu-flags.pl \
        "$out/bin/qemu-system-x86_64" max-x86_64-cpu > "$out/share/qemu/recognized-CPUID-flags-x86_64"

      for arch in x86_64 aarch64; do
        "$out/bin/qemu-system-$arch" -machine help \
          | ${perlEnv}/bin/perl ${pveSrc}/debian/parse-machines.pl > "$out/share/qemu/machine-versions-$arch.json"
        "$out/bin/qemu-system-$arch" -cpu help \
          | ${perlEnv}/bin/perl ${pveSrc}/debian/parse-cpu-models.pl > "$out/share/qemu/cpu-models-$arch.json"
      done
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
    enableDocs = false;
    cephSupport = lib.meta.availableOn stdenv.hostPlatform ceph;
  }
