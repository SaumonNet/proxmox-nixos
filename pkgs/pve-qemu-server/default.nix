{
  lib,
  stdenv,
  fetchgit,
  perl536,
  glib,
  json_c,
  pkg-config,
  proxmox-backup-client,
  pve-edk2-firmware,
  pve-qemu,
  util-linux,
  uuid,
  findbin,
  termreadline,
  socat,
  vncterm,
}:

let
  perlDeps = with perl536.pkgs; [
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

  perlEnv = perl536.withPackages (_: perlDeps);
in

perl536.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-qemu-server";
    version = "8.2.1";

    src = fetchgit {
      url = "git://git.proxmox.com/git/qemu-server.git";
      rev = "54aa98cea5071b5cd325cfaeb21b7aaa4af9bb4d";
      hash = "sha256-KjMkOTYrrXBB2HP9bXVJjDlBi86REe3lc8nEnUjZdls=";
    };

    postPatch = ''
      sed -i {qmeventd/,}Makefile \
        -e "/GITVERSION/d" \
        -e "/default.mk/d" \
        -e "/pve-doc-generator/d" \
        -e "/install -m 0644 -D qm.bash-completion/,+4d" \
        -e "/install -m 0644 qm.1/,+4d" \
        -e "s/qmeventd docs/qmeventd/" \
        -e "/qmeventd.8/d" \
        -e "/SERVICEDIR/d" \
        -e "/modules-load.conf/d" \
        -e "s,usr/,,g"

      # Fix QEMU version check
      sed -i PVE/QemuServer.pm -e "s/\[,\\\s\]//"

    '';

    buildInputs = [
      glib
      json_c
      pkg-config
      perlEnv
    ];
    propagatedBuildInputs = perlDeps;
    dontPatchShebangs = true;

    makeFlags = [
      "PKGSOURCES=qm qmrestore qmextract"
      "DESTDIR=$(out)"
      "PREFIX="
      "SBINDIR=/.bin"
      "USRSHAREDIR=$(out)/share/qemu-server"
      "VARLIBDIR=$(out)/lib/qemu-server"
      "PERLDIR=/${perl536.libPrefix}/${perl536.version}"
    ];

    postFixup = ''
      find $out/lib -type f | xargs sed -i \
        -e "/ENV{'PATH'}/d" \
        -e "s|/usr/lib/qemu-server|$out/lib/qemu-server|" \
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
        #-e "s|/usr/bin/proxmox-backup-client|${proxmox-backup-client}/bin/proxmox-backup-client|" \
        #-e "s|/usr/sbin/qm|$out/bin/qm|" \
        #-e "s|/usr/bin/qemu|${pve-qemu}/bin/qemu|" \
        #-e "s|/usr/bin/taskset|${util-linux}/bin/taskset|" \
        #-e "s|/usr/bin/vncterm||" \
        #-e "s|/usr/bin/termproxy||" \
        #-e "s|/usr/bin/vma||" \
        #-e "s|/usr/bin/pbs-restore||" \
        patchShebangs $out/lib/qemu-server/pve-bridge
        patchShebangs $out/lib/qemu-server/pve-bridgedown
        patchShebangs $out/lib/qemu-server/pve-bridge-hotplug
        patchShebangs $out/lib/qemu-server/qmextract
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
