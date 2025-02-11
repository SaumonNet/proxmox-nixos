{
  lib,
  qemu,
  fetchgit,
  proxmox-backup-qemu,
  perl538,
  pkg-config,
  meson,
  cacert
}:

(
  (qemu.overrideAttrs (old: rec {
    pname = "pve-qemu";
    version = "9.2.0-1";

    src = fetchgit {
      url = "git://git.proxmox.com/git/pve-qemu.git";
      rev = "4f4fca78f7bb0ea6e4df6adda0b498e1918a5355";
      hash = "sha256-oCRCxBTpmUR3JGEq1lFg8mfzkdXUxE6TSBeRcd9laG8=";
      fetchSubmodules = true;
      # Download subprojects managed by meson
      postFetch = ''
        cd "$out/qemu"
        export NIX_SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
        for prj in subprojects/*.wrap; do
          ${lib.getExe meson} subprojects download "$(basename "$prj" .wrap)"
        done
        find subprojects -type d -name .git -prune -execdir rm -r {} +
        rm -rf subprojects/packagecache/tmp*
    '';
    };

    patches =
      let
        series = builtins.readFile "${src}/debian/patches/series";
        patchList = builtins.filter (patch: builtins.isString patch && patch != "") (
          builtins.split "\n" series
        );
        patchPathsList = map (patch: "${src}/debian/patches/${patch}") patchList;
      in
      old.patches ++ patchPathsList;

    sourceRoot = "${src.name}/qemu";

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

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
      "--version-prefix"
      (lib.versions.majorMinor old.version)
    ];
  })).override
  {
    glusterfsSupport = true;
    enableDocs = false;
    cephSupport = true;
  }
)
