{
  lib,
  qemu,
  fetchgit,
  proxmox-backup-qemu,
  perl540,
  pkg-config,
  meson,
  cacert,
  pve-update-script,
}:

let
  perlDeps = with perl540.pkgs; [ JSON ];
  perlEnv = perl540.withPackages (_: perlDeps);
in
(qemu.overrideAttrs (old: rec {
  pname = "pve-qemu";
  version = "10.0.2-4";

  src =
    (fetchgit {
      url = "git://git.proxmox.com/git/pve-qemu.git";
      rev = "839b53bab89fddb7a7fb3a1d722e05df932cce4e";
      hash = "sha256-pu0Mp4F1ppmD1R0O31c8tm0jTlfsxuxYFN03+YPrtBc=";
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
    }).overrideAttrs
      (_: {
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

  preBuild = ''
    cp ${proxmox-backup-qemu}/lib/proxmox-backup-qemu.h .
  ''
  + old.preBuild;

  nativeBuildInputs = old.nativeBuildInputs ++ [
    proxmox-backup-qemu
    perlEnv
    pkg-config
  ];

  # Generate cpu flag files and machine versions json
  # This is done in /debian/rules of pve-qemu, and needed by pve-qemu-server
  postInstall = old.postInstall + ''
    $out/bin/qemu-system-x86_64 -cpu help \
      | ${perlEnv}/bin/perl ${src}/debian/parse-cpu-flags.pl > $out/share/qemu/recognized-CPUID-flags-x86_64
    $out/bin/qemu-system-x86_64 -machine help \
      | ${perlEnv}/bin/perl ${src}/debian/parse-machines.pl > $out/share/qemu/machine-versions-x86_64.json
  '';

  passthru.updateScript = pve-update-script {
    extraArgs = [
      "--deb-name"
      "pve-qemu-kvm"
    ];
  };

  meta.position = builtins.dirOf ./.;
})).override
  {
    glusterfsSupport = true;
    enableDocs = false;
    cephSupport = true;
  }
