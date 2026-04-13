{
  lib,
  stdenv,
  fetchgit,
  perl5,
  glib,
  json_c,
  pkgconf,
  libsysprof-capture,
  pcre2,
  proxmox-backup-client,
  pve-edk2-firmware,
  pve-firewall,
  pve-qemu,
  util-linux,
  uuid,
  findbin,
  termreadline,
  socat,
  vncterm,
  swtpm,
  libglvnd,
  virtiofsd,
  pve-update-script,
  python3Packages,
}:

let
  perlDeps = with perl5.pkgs; [
    CryptOpenSSLRandom
    DataDumper
    DigestSHA
    FilePath
    findbin
    HTTPMessage
    GetoptLong
    IO
    IOMultiplex
    IOSocketIP
    JSON
    MIMEBase64
    NetSSLeay
    PathTools
    pve-firewall
    ScalarListUtils
    Socket
    Storable
    termreadline
    TestHarness
    TestMockModule
    TestMore
    TimeHiRes
    uuid
    XMLLibXML
  ];

  perlEnv = perl5.withPackages (_: perlDeps);
in

perl5.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-qemu-server";
    version = "9.2.5";

    src = fetchgit {
      url = "git://git.proxmox.com/git/qemu-server.git";
      rev = "0f5055d88e1458117d7f716265285d28978a9d1d";
      hash = "sha256-AyTLGJQvyxHN7oAcUO3dr8FNtM2aenZEQXtWXeZ2C8E=";
    };

    sourceRoot = "${src.name}/src";

    postPatch = ''
      sed -i {qmeventd/,bin/}Makefile \
        -e "/GITVERSION/d" \
        -e "/default.mk/d" \
        -e "/pve-doc-generator/d" \
        -e "/install -m 0644 -D qm.bash-completion/,+3d" \
        -e "/install -m 0644 qm.1/,+4d" \
        -e "s/qmeventd docs/qmeventd/" \
        -e "/qmeventd.8/d" \
        -e "/modules-load.conf/d" \
        -e "s,usr/,,g"

      # qmeventd should resolve qm from PATH instead of relying on /usr/sbin.
      for file in $(grep -rl '/usr/sbin/qm' qmeventd bin PVE); do
        sed -i -e 's!/usr/sbin/qm!qm!g' "$file"
      done

      # Fix QEMU version check
      sed -i PVE/QemuServer/Helpers.pm -e "s/\[,\\\s\]//"

      # Fix libGL and libEGL detection
      substituteInPlace PVE/QemuServer.pm \
        --replace-fail 'my $base = "/usr/lib/''${host_arch}-linux-gnu/lib";' \
        'my $base = "${libglvnd}/lib/lib";'

      # Fix Microsoft 2023 KEK cert path for `qm enroll-efi-keys`. Proxmox
      # hardcodes the pre-2025 virt-firmware layout (matching Debian Trixie's
      # v24.11), but nixpkgs ships virt-firmware >= 25.10 which moved the
      # certs into a microsoft.com/ subdir with shorter names (upstream
      # kraxel/virt-firmware@d2fb90a, 2025-03-17).
      substituteInPlace PVE/QemuServer/OVMF.pm \
        --replace-fail \
          "'/usr/lib/python3/dist-packages/virt/firmware/certs/'" \
          "'${python3Packages.virt-firmware}/${python3Packages.python.sitePackages}/virt/firmware/certs/microsoft.com/'" \
        --replace-fail \
          "'MicrosoftCorporationKEK2KCA2023.pem'" \
          "'ms-kek-2023.pem'"
    '';

    buildInputs = [
      glib
      json_c
      pkgconf
      perlEnv
      libsysprof-capture
      pcre2
    ];
    propagatedBuildInputs = perlDeps;
    dontPatchShebangs = true;

    dontBuild = true;

    # Create missing dirs
    preInstall = ''
      mkdir -p $out/lib/systemd/system
      mkdir -p $out/share/dbus-1/system.d
    '';

    installPhase = ''
      runHook preInstall

      make install \
        PKGSOURCES="qm qmrestore qmextract" \
        DESTDIR=$out \
        PREFIX= \
        SBINDIR=/.bin \
        USRSHAREDIR=$out/share/qemu-server \
        PERLDIR=/${perl5.libPrefix}/${perl5.version}

      runHook postInstall
    '';

    postFixup = ''
      mv "$out"/usr/lib/systemd/system/* "$out/lib/systemd/system/"
      mv "$out"/usr/share/dbus-1/system.d/* "$out/share/dbus-1/system.d/"

      find $out/lib $out/libexec -type f | xargs sed -i \
        -e "/ENV{'PATH'}/d" \
        -e "s|/usr/lib/qemu-server|$out/lib/qemu-server|" \
        -e "s|/usr/libexec/qemu-server|$out/libexec/qemu-server|" \
        -e "s|/usr/share/qemu-server|$out/share/qemu-server|" \
        -e "s|/usr/share/kvm|${pve-qemu}/share/qemu|" \
        -Ee "s|(/usr)?/s?bin/kvm|qemu-kvm|" \
        -Ee "s|(/usr)?/s?bin/||" \
        -e "s|socat|${socat}/bin/socat|" \
        -e "s|vncterm|${vncterm}/bin/vncterm|" \
        -e "s|qemu-kvm|${pve-qemu}/bin/qemu-kvm|" \
        -e "s|qemu-system|${pve-qemu}/bin/qemu-system|" \
        -e "s|/var/lib/qemu-server|$out/lib/qemu-server|" \
        -e "s|/usr/share/pve-edk2-firmware|${pve-edk2-firmware}/usr/share/pve-edk2-firmware|" \
        -e 's|/etc/swtpm_setup.conf|${swtpm}/etc/swtpm_setup.conf|' \
        -e "s|virt-fw-vars|${python3Packages.virt-firmware}/bin/virt-fw-vars|g" \
        -e "s|/usr/libexec/virtiofsd|${virtiofsd}/bin/virtiofsd|" \
        #-e "s|/usr/bin/proxmox-backup-client|${proxmox-backup-client}/bin/proxmox-backup-client|" \
        #-e "s|/usr/sbin/qm|$out/bin/qm|" \
        #-e "s|/usr/bin/qemu|${pve-qemu}/bin/qemu|" \
        #-e "s|/usr/bin/taskset|${util-linux}/bin/taskset|" \
        #-e "s|/usr/bin/vncterm||" \
        #-e "s|/usr/bin/termproxy||" \
        #-e "s|/usr/bin/vma||" \
        #-e "s|/usr/bin/pbs-restore||" \

      find $out/lib/systemd/system -type f | xargs sed -i \
        -e "s|/usr/libexec/qemu-server|$out/libexec/qemu-server|"

      patchShebangs $out/lib/
      patchShebangs $out/libexec/
    '';

    passthru.updateScript = pve-update-script {
      extraArgs = [
        "--deb-name"
        "qemu-server"
      ];
    };

    meta = with lib; {
      description = "Proxmox VE's Virtual Machine Manager";
      homepage = "https://git.proxmox.com/?p=qemu-server.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
