{
  lib,
  stdenv,
  fetchgit,
  perl538,
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
  targetcli,
  util-linux,
  zfs,
  posixstrptime,
}:

let
  perlDeps =
    with perl538.pkgs;
    [
      Filechdir
      posixstrptime
      pve-cluster
      pve-rados2
    ]
    ++ lib.optional enableLinstor linstor-proxmox;

  perlEnv = perl538.withPackages (_: perlDeps);
in

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-storage";
    version = "8.3.3";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "e5f4af47d08322dd6d9b9c71cae24a9eb89e8756";
      hash = "sha256-DuKG8V3T88bzDlTbvKzIiiOI/kXPpPZpMGe0KyKZnSc=";
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
      "PERLDIR=/${perl538.libPrefix}/${perl538.version}"
    ];

    postInstall =
      ''
        sed -i $out/bin/* \
          -e "s/-T//" \
          -e "1s|$| -I$out/${perl538.libPrefix}/${perl538.version}|"
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
        -e "s|/usr/bin/targetcli|${targetcli}/bin/targetcli|" \
        -e "s|/usr/libexec/ceph|$out/libexec/ceph|" \
        -re "s|/usr/s?bin/ceph|${ceph}/bin/ceph|" \
        -e "s|/usr/sbin/gluster|${glusterfs}/bin/gluster|" \
        -e "s|/usr/sbin/ietadm||" \
        -e "s|/usr/sbin/pvesm|$out/bin/pvesm|" \
        -e "s|/usr/sbin/rpcinfo|${rpcbind}/bin/rpcinfo|" \
        -e "s|/usr/sbin/sbdadm||" \
        -e "s|/usr/sbin/smartctl|${smartmontools}/bin/smartctl|" \
        -e "s|/usr/sbin/stmfadm||" \
        -e "s|/usr/share/perl5|$out/${perl538.libPrefix}/${perl538.version}|"
    '';

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
    ];

    meta = with lib; {
      description = "Proxmox VE Storage Library";
      homepage = "git://git.proxmox.com/?p=pve-storage.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
