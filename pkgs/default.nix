{ pkgs, ... }:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // ours);
  ours = rec {
    markedjs = callPackage ./markedjs.nix { };
    proxmox-ve = callPackage ./pve { };
    pve-novnc = callPackage ./novnc { };
    proxmox-widget-toolkit = callPackage ./widget-toolkit.nix { };
    perlmod = callPackage ./perlmod { };
    pve-access-control = callPackage ./pve/access-control.nix { };
    pve-acme = callPackage ./pve/acme.nix { };
    pve-apiclient = callPackage ./pve/apiclient.nix { };
    pve-cluster = callPackage ./pve/cluster.nix { };
    pve-common = callPackage ./pve/common.nix { };
    pve-container = callPackage ./pve/container.nix { };
    pve-docs = callPackage ./pve/docs.nix { };
    pve-firewall = callPackage ./pve/firewall.nix { };
    pve-ha-manager = callPackage ./pve/ha-manager.nix { };
    pve-http-server = callPackage ./pve/http-server.nix { };
    pve-guest-common = callPackage ./pve/guest-common.nix { };
    pve-manager = callPackage ./pve/manager.nix { };
    pve-storage = callPackage ./pve/storage.nix { };
    pve-rados2 = callPackage ./pve/rados2.nix { };
    pve-rs = callPackage ./pve/rs { };
    pve-xtermjs = callPackage ./pve/xtermjs.nix { };
    termproxy = callPackage ./rs/termproxy { };
    pve-qemu-server = callPackage ./pve/qemu-server.nix { };
    pve-qemu = (pkgs.qemu.overrideAttrs (old: {
      patches = old.patches ++ [
        ./pve/qemu/extra/0001-monitor-qmp-fix-race-with-clients-disconnecting-earl.patch
        ./pve/qemu/extra/0002-scsi-megasas-Internal-cdbs-have-16-byte-length.patch
        ./pve/qemu/extra/0003-ide-avoid-potential-deadlock-when-draining-during-tr.patch
        ./pve/qemu/extra/0004-migration-block-dirty-bitmap-fix-loading-bitmap-when.patch
        #./pve/qemu/extra/0005-hw-ide-reset-cancel-async-DMA-operation-before-reset.patch
        #./pve/qemu/extra/0006-Revert-Revert-graph-lock-Disable-locking-for-now.patch
        #./pve/qemu/extra/0007-migration-states-workaround-snapshot-performance-reg.patch
        #./pve/qemu/bitmap-mirror/0001-drive-mirror-add-support-for-sync-bitmap-mode-never.patch
        #./pve/qemu/bitmap-mirror/0002-drive-mirror-add-support-for-conditional-and-always-.patch
        #./pve/qemu/bitmap-mirror/0003-mirror-add-check-for-bitmap-mode-without-bitmap.patch
        #./pve/qemu/bitmap-mirror/0004-mirror-switch-to-bdrv_dirty_bitmap_merge_internal.patch
        #./pve/qemu/bitmap-mirror/0005-iotests-add-test-for-bitmap-mirror.patch
        #./pve/qemu/bitmap-mirror/0006-mirror-move-some-checks-to-qmp.patch
        #./pve/qemu/pve/0001-PVE-Config-block-file-change-locking-default-to-off.patch
        #./pve/qemu/pve/0002-PVE-Config-Adjust-network-script-path-to-etc-kvm.patch
        #./pve/qemu/pve/0003-PVE-Config-set-the-CPU-model-to-kvm64-32-instead-of-.patch
        #./pve/qemu/pve/0004-PVE-Config-ui-spice-default-to-pve-certificates.patch
        #./pve/qemu/pve/0005-PVE-Config-glusterfs-no-default-logfile-if-daemonize.patch
        #./pve/qemu/pve/0006-PVE-Config-rbd-block-rbd-disable-rbd_cache_writethro.patch
        #./pve/qemu/pve/0007-PVE-Up-glusterfs-allow-partial-reads.patch
        #./pve/qemu/pve/0008-PVE-Up-qemu-img-return-success-on-info-without-snaps.patch
        #./pve/qemu/pve/0009-PVE-Up-qemu-img-dd-add-osize-and-read-from-to-stdin-.patch
        #./pve/qemu/pve/0010-PVE-Up-qemu-img-dd-add-isize-parameter.patch
        #./pve/qemu/pve/0011-PVE-Up-qemu-img-dd-add-n-skip_create.patch
        #./pve/qemu/pve/0012-qemu-img-dd-add-l-option-for-loading-a-snapshot.patch
        #./pve/qemu/pve/0013-PVE-virtio-balloon-improve-query-balloon.patch
        ./pve/qemu/pve/0014-PVE-qapi-modify-query-machines.patch
        ./pve/qemu/pve/0015-PVE-qapi-modify-spice-query.patch
        #./pve/qemu/pve/0016-PVE-add-IOChannel-implementation-for-savevm-async.patch
        #./pve/qemu/pve/0017-PVE-add-savevm-async-for-background-state-snapshots.patch
        #./pve/qemu/pve/0018-PVE-add-optional-buffer-size-to-QEMUFile.patch
        #./pve/qemu/pve/0019-PVE-block-add-the-zeroinit-block-driver-filter.patch
        ./pve/qemu/pve/0020-PVE-Add-dummy-id-command-line-parameter.patch
        #./pve/qemu/pve/0021-PVE-Config-Revert-target-i386-disable-LINT0-after-re.patch
        #./pve/qemu/pve/0022-PVE-Up-Config-file-posix-make-locking-optiono-on-cre.patch
        #./pve/qemu/pve/0023-PVE-monitor-disable-oob-capability.patch
        #./pve/qemu/pve/0024-PVE-Compat-4.0-used-balloon-qemu-4-0-config-size-fal.patch
        ./pve/qemu/pve/0025-PVE-Allow-version-code-in-machine-type.patch
        #./pve/qemu/pve/0026-block-backup-move-bcs-bitmap-initialization-to-job-c.patch
        #./pve/qemu/pve/0027-PVE-Backup-add-vma-backup-format-code.patch
        #./pve/qemu/pve/0028-PVE-Backup-add-backup-dump-block-driver.patch
        #./pve/qemu/pve/0029-PVE-Add-sequential-job-transaction-support.patch
        #./pve/qemu/pve/0030-PVE-Backup-Proxmox-backup-patches-for-QEMU.patch
        #./pve/qemu/pve/0031-PVE-Backup-pbs-restore-new-command-to-restore-from-p.patch
        #./pve/qemu/pve/0032-PVE-Add-PBS-block-driver-to-map-backup-archives-into.patch
        #./pve/qemu/pve/0033-PVE-redirect-stderr-to-journal-when-daemonized.patch
        #./pve/qemu/pve/0034-PVE-Migrate-dirty-bitmap-state-via-savevm.patch
        #./pve/qemu/pve/0035-migration-block-dirty-bitmap-migrate-other-bitmaps-e.patch
        #./pve/qemu/pve/0036-PVE-fall-back-to-open-iscsi-initiatorname.patch
        #./pve/qemu/pve/0037-PVE-block-stream-increase-chunk-size.patch
        #./pve/qemu/pve/0038-block-io-accept-NULL-qiov-in-bdrv_pad_request.patch
        #./pve/qemu/pve/0039-block-add-alloc-track-driver.patch
        #./pve/qemu/pve/0040-Revert-block-rbd-workaround-for-ceph-issue-53784.patch
        #./pve/qemu/pve/0041-Revert-block-rbd-fix-handling-of-holes-in-.bdrv_co_b.patch
        #./pve/qemu/pve/0042-Revert-block-rbd-implement-bdrv_co_block_status.patch
        #./pve/qemu/pve/0043-alloc-track-fix-deadlock-during-drop.patch
        #./pve/qemu/pve/0044-migration-for-snapshots-hold-the-BQL-during-setup-ca.patch
        #./pve/qemu/pve/0045-savevm-async-don-t-hold-BQL-during-setup.patch
      ];
    })).override { glusterfsSupport = true; };
  };
in
ours
