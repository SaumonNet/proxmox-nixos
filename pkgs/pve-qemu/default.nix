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

let 
  perlDeps = with perl538.pkgs; [ JSON ];
  perlEnv = perl538.withPackages (_: perlDeps);
in 
(
  (qemu.overrideAttrs (old: rec {
    pname = "pve-qemu";
    version = "9.2.0-7";

    src = (fetchgit {
      url = "git://git.proxmox.com/git/pve-qemu.git";
      rev = "245689b9ae4120994de29b71595ea58abac06f3c";
      hash = "sha256-JTcTUVC8vmv7yrtpE7deCN7zkZmiCC1Z0lLXackuY/8=";
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
    }).overrideAttrs (_: {
      GIT_CONFIG_COUNT = 2;
      
      GIT_CONFIG_KEY_0 = "url.https://github.com/qemu/u-boot-sam460ex.git.insteadOf";
      GIT_CONFIG_VALUE_0 = "https://gitlab.com/qemu-project/u-boot-sam460ex.git";
      
      GIT_CONFIG_KEY_1 = "url.https://github.com/u-boot/u-boot.git.insteadOf";
      GIT_CONFIG_VALUE_1 = "https://gitlab.com/qemu-project/u-boot.git";
    });

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
      perlEnv
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

    # Generate cpu flag files and machine versions json
    # This is done in /debian/rules of pve-qemu, and needed by pve-qemu-server
    postInstall = old.postInstall + ''
      $out/bin/qemu-system-x86_64 -cpu help \
        | ${perlEnv}/bin/perl ${src}/debian/parse-cpu-flags.pl > $out/share/qemu/recognized-CPUID-flags-x86_64
      $out/bin/qemu-system-x86_64 -machine help \
        | ${perlEnv}/bin/perl ${src}/debian/parse-machines.pl > $out/share/qemu/machine-versions-x86_64.json
    '';
  })).override
  {
    glusterfsSupport = true;
    enableDocs = false;
    cephSupport = true;
  }
)
