{
  lib,
  stdenv,
  fetchgit,
  perl538,
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
}:

let
  perlDeps = with perl538.pkgs; [
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

  perlEnv = perl538.withPackages (_: perlDeps);
in

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-qemu-server";
    version = "8.4.2";

    src = fetchgit {
      url = "git://git.proxmox.com/git/qemu-server.git";
      rev = "14abf7b3589605d744e7ff03d21c5f5fc8a13cbe";
      hash = "sha256-tQBKrsFRVPIAtbRKOu2+m2Ez9iHdNeq7XEsaQLleEUQ=";
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

      # Fix QEMU version check
      sed -i PVE/QemuServer/Helpers.pm -e "s/\[,\\\s\]//"

      # Fix libGL and libEGL detection
      sed -i PVE/QemuServer.pm -e "s|/usr/lib/x86_64-linux-gnu/lib|${libglvnd}/lib/lib|"
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

    # Create missing SERVICEDIR
    preInstall = ''
      mkdir -p $out/lib/systemd/system
    '';

    installPhase = ''
      runHook preInstall

      make install \
        PKGSOURCES="qm qmrestore qmextract" \
        DESTDIR=$out \
        PREFIX= \
        SBINDIR=/.bin \
        USRSHAREDIR=$out/share/qemu-server \
        PERLDIR=/${perl538.libPrefix}/${perl538.version}

      runHook postInstall
    '';

    postFixup = ''
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
        #-e "s|/usr/bin/proxmox-backup-client|${proxmox-backup-client}/bin/proxmox-backup-client|" \
        #-e "s|/usr/sbin/qm|$out/bin/qm|" \
        #-e "s|/usr/bin/qemu|${pve-qemu}/bin/qemu|" \
        #-e "s|/usr/bin/taskset|${util-linux}/bin/taskset|" \
        #-e "s|/usr/bin/vncterm||" \
        #-e "s|/usr/bin/termproxy||" \
        #-e "s|/usr/bin/vma||" \
        #-e "s|/usr/bin/pbs-restore||" \

      patchShebangs $out/lib/
      patchShebangs $out/libexec/
    '';

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
    ];

    meta = with lib; {
      description = "Proxmox VE's Virtual Machine Manager";
      homepage = "git://git.proxmox.com/?p=qemu-server.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
