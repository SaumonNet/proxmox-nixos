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
    version = "9.2.0-5";

    src = fetchgit {
      url = "git://git.proxmox.com/git/pve-qemu.git";
      rev = "e0969989ac8ba252891a1a178b71e068c8ed4995";
      hash = "sha256-wIrvaSjatyQq3a897ScljxmivUIM80rvc0F0y2tIZWo=";
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
