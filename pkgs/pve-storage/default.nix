{
  lib,
  stdenv,
  fetchgit,
  perl540,
  pve-cluster,
  pve-rados2,
  enableLinstor ? false,
  linstor-proxmox,
  ceph,
  coreutils,
  e2fsprogs,
  file,
  glusterfs,
  gptfdisk,
  gzip,
  libiscsi,
  lvm2,
  nfs-utils,
  openiscsi,
  openssh,
  proxmox-backup-client,
  pve-qemu,
  rpcbind,
  samba,
  smartmontools,
  targetcli-fb,
  util-linux,
  zfs,
  posixstrptime,
  pve-update-script,
}:

let
  perlDeps =
    with perl540.pkgs;
    [
      Filechdir
      XMLLibXML
      posixstrptime
      pve-cluster
      pve-rados2
    ]
    ++ lib.optional enableLinstor linstor-proxmox;

  perlEnv = perl540.withPackages (_: perlDeps);
in

perl540.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-storage";
    version = "9.1.0";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "6f49432acc6d030017c5f8833a17b33c6ae00324";
      hash = "sha256-jyDunxby8WPR3BnqdmbOVbHKOERwchhsEb4WYo0j2q8=";
    };

    sourceRoot = "${src.name}/src";

    postPatch = ''
      sed -i bin/Makefile \
        -e "s/pvesm.1 pvesm.bash-completion pvesm.zsh-completion//" \
        -e "/pvesm.1/,+3d"
    '';

    buildInputs = [ perlEnv ];
    propagatedBuildInputs = perlDeps;

    makeFlags = [
      "DESTDIR=$(out)"
      "PREFIX="
      "SBINDIR=/bin"
      "PERLDIR=/${perl540.libPrefix}/${perl540.version}"
    ];

    postInstall = ''
      sed -i $out/bin/* \
        -e "s/-T//" \
        -e "1s|$| -I$out/${perl540.libPrefix}/${perl540.version}|"
    ''
    + lib.optionalString enableLinstor ''
      cp -rs ${linstor-proxmox}/lib $out
    '';

    postFixup = ''
      find $out -type f | xargs sed -i \
        -e "s|/bin/lsblk|${util-linux}/bin/lsblk|" \
        -e "s|/bin/mkdir|${coreutils}/bin/mkdir|" \
        -e "s|/bin/mount|${util-linux}/bin/mount|" \
        -e "s|/bin/umount|${util-linux}/bin/umount|" \
        -e "s|/sbin/blkid|${util-linux}/bin/blkid|" \
        -e "s|/sbin/blockdev|${util-linux}/bin/blockdev|" \
        -e "s|/sbin/lv|${lvm2.bin}/bin/lv|" \
        -e "s|/sbin/mkfs|${util-linux}/bin/mkfs|" \
        -e "s|/sbin/pv|${lvm2.bin}/bin/vg|" \
        -e "s|/sbin/sgdisk|${gptfdisk}/bin/sgdisk|" \
        -e "s|/sbin/showmount|${nfs-utils}/bin/showmount|" \
        -e "s|/sbin/vg|${lvm2.bin}/bin/vg|" \
        -e "s|/sbin/zfs|${zfs}/bin/zfs|" \
        -e "s|/sbin/zpool|${zfs}/bin/zpool|" \
        -e "s|/usr/bin/chattr|${e2fsprogs}/bin/chattr|" \
        -e "s|/usr/bin/cstream||" \
        -e "s|/usr/bin/file|${file}/bin/file|" \
        -e "s|/usr/bin/iscsi-ls|${libiscsi}/bin/iscsi-ls|" \
        -e "s|/usr/bin/iscsiadm|${openiscsi}/bin/iscsiadm|" \
        -e "s|/usr/bin/proxmox-backup-client|${proxmox-backup-client}/bin/proxmox-backup-client|" \
        -e "s|/usr/bin/qemu|${pve-qemu}/bin/qemu|" \
        -e "s|/usr/bin/rados|${ceph}/bin/rados|" \
        -e "s|/usr/bin/rbd|${ceph}/bin/rbd|" \
        -e "s|/usr/bin/scp|${openssh}/bin/scp|" \
        -e "s|/usr/bin/smbclient|${samba}/bin/smbclient|" \
        -e "s|/usr/bin/ssh|${openssh}/bin/ssh|" \
        -e "s|/usr/bin/targetcli|${targetcli-fb}/bin/targetcli|" \
        -e "s|/usr/bin/vma|${pve-qemu}/bin/vma|" \
        -e "s|/usr/bin/zcat|${gzip}/bin/zcat|" \
        -e "s|/usr/libexec/ceph|$out/libexec/ceph|" \
        -re "s|/usr/s?bin/ceph|${ceph}/bin/ceph|" \
        -e "s|/usr/sbin/gluster|${glusterfs}/bin/gluster|" \
        -e "s|/usr/sbin/ietadm||" \
        -e "s|/usr/sbin/pvesm|$out/bin/pvesm|" \
        -e "s|/usr/sbin/rpcinfo|${rpcbind}/bin/rpcinfo|" \
        -e "s|/usr/sbin/sbdadm||" \
        -e "s|/usr/sbin/smartctl|${smartmontools}/bin/smartctl|" \
        -e "s|/usr/sbin/stmfadm||" \
        -e "s|/usr/share/perl5|$out/${perl540.libPrefix}/${perl540.version}|"
    '';

    passthru.updateScript = pve-update-script {
      extraArgs = [
        "--deb-name"
        "libpve-storage-perl"
      ];
    };

    meta = with lib; {
      description = "Proxmox VE Storage Library";
      homepage = "https://git.proxmox.com/?p=pve-storage.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
