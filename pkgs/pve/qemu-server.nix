{ lib
, stdenv
, fetchFromGitHub
, callPackage
, perl
, glib
, json_c
, pkg-config
, proxmox-backup-client
, pve-qemu
, util-linux
}:

let
  perlDeps = with perl.pkgs; with callPackage ../perl-packages.nix { }; [
    CryptOpenSSLRandom
    DataDumper
    DigestSHA
    FilePath
    FindBin
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
    TermReadLine
    TestHarness
    TestMockModule
    TestMore
    TimeHiRes
    URI
    UUID
    XMLLibXML
  ];

  perlEnv = perl.withPackages (_: perlDeps);
in

perl.pkgs.toPerlModule (stdenv.mkDerivation {
  pname = "pve-qemu-server";
  version = "8.0.6";

  src = fetchFromGitHub {
    owner = "proxmox";
    repo = "qemu-server";
    rev = "f46596539f9684959b93e518010b7ecb24b34bf4";
    hash = "sha256-LUOryKOqEPHCxdjBBqrTnefIa0T3QbLURPgpYtf/bEA=";
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

  buildInputs = [ glib json_c pkg-config perlEnv ];
  propagatedBuildInputs = perlDeps;
  dontPatchShebangs = true;

  makeFlags = [
    "PKGSOURCES=qm qmrestore qmextract"
    "DESTDIR=$(out)"
    "PREFIX="
    "SBINDIR=/.bin"
    "USRSHAREDIR=$(out)/share/qemu-server"
    "VARLIBDIR=$(out)/lib/qemu-server"
    "PERLDIR=/${perl.libPrefix}/${perl.version}"
  ];

  postFixup = ''
    find $out/lib -type f | xargs sed -i \
      -e "/ENV{'PATH'}/d" \
      -e "s|/usr/lib/qemu-server|$out/lib/qemu-server|" \
      -e "s|/usr/share/qemu-server|$out/share/qemu-server|" \
      -e "s|/usr/share/kvm|${pve-qemu}/share/qemu|" \
      -Ee "s|(/usr)?/s?bin/kvm|qemu-kvm|" \
      -Ee "s|(/usr)?/s?bin/||" \
      -e "s|qemu-kvm|${pve-qemu}/bin/qemu-kvm|" \
      -e "s|qemu-system|${pve-qemu}/bin/qemu-system|"

      #-e "s|/usr/bin/proxmox-backup-client|${proxmox-backup-client}/bin/proxmox-backup-client|" \
      #-e "s|/usr/sbin/qm|$out/bin/qm|" \
      #-e "s|/usr/bin/qemu|${pve-qemu}/bin/qemu|" \
      #-e "s|/usr/bin/taskset|${util-linux}/bin/taskset|" \
      #-e "s|/usr/bin/vncterm||" \
      #-e "s|/usr/bin/termproxy||" \
      #-e "s|/usr/bin/vma||" \
      #-e "s|/usr/bin/pbs-restore||" \
  '';

  meta = with lib; {
    description = "Proxmox VE's Virtual Machine Manager";
    homepage = "https://github.com/proxmox/qemu-server";
    license = with licenses; [ ];
    maintainers = with maintainers; [ camillemndn julienmalka ];
    platforms = platforms.linux;
  };
})
