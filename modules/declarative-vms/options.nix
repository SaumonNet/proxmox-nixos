{ lib, ... }:

with lib;

let
  commonVolumeOptions = {
    options = {
      file = mkOption {
        type = types.str;
        description = "The volume file.";
        example = "/path/to/volume.img";
      };
      aio = mkOption {
        type = types.nullOr types.str;
        description = "Asynchronous I/O mode.";
        example = "native";
        default = null;
      };
      backup = mkOption {
        type = types.nullOr types.bool;
        description = "Whether to backup.";
        example = true;
        default = null;
      };
      bps = mkOption {
        type = types.nullOr types.str;
        description = "Bytes per second rate.";
        example = "10M";
        default = null;
      };
      bps_max_length = mkOption {
        type = types.nullOr types.int;
        description = "Maximum length in seconds for BPS.";
        example = 60;
        default = null;
      };
      bps_rd = mkOption {
        type = types.nullOr types.str;
        description = "Read BPS rate.";
        example = "5M";
        default = null;
      };
      bps_rd_max_length = mkOption {
        type = types.nullOr types.int;
        description = "Maximum length in seconds for read BPS.";
        example = 30;
        default = null;
      };
      bps_wr = mkOption {
        type = types.nullOr types.str;
        description = "Write BPS rate.";
        example = "5M";
        default = null;
      };
      bps_wr_max_length = mkOption {
        type = types.nullOr types.int;
        description = "Maximum length in seconds for write BPS.";
        example = 30;
        default = null;
      };
      cache = mkOption {
        type = types.nullOr types.str;
        description = "Cache mode.";
        example = "none";
        default = null;
      };
      cyls = mkOption {
        type = types.nullOr types.int;
        description = "Number of cylinders.";
        example = 1024;
        default = null;
      };
      detect_zeroes = mkOption {
        type = types.nullOr types.bool;
        description = "Whether to detect zeroes.";
        example = false;
        default = null;
      };
      discard = mkOption {
        type = types.nullOr types.str;
        description = "Discard mode.";
        example = "ignore";
        default = null;
      };
      format = mkOption {
        type = types.nullOr types.str;
        description = "Disk format.";
        default = null;
        example = "qcow2";
      };
      heads = mkOption {
        type = types.nullOr types.int;
        description = "Number of disk heads.";
        example = 16;
        default = null;
      };
      import-from = mkOption {
        type = types.nullOr types.str;
        description = "Source volume to import from.";
        example = "/path/to/source-volume.img";
        default = null;
      };
      iops = mkOption {
        type = types.nullOr types.str;
        description = "IO operations per second rate.";
        example = "1000";
        default = null;
      };
      iops_max = mkOption {
        type = types.nullOr types.str;
        description = "Maximum IOPS rate.";
        example = "2000";
        default = null;
      };
      iops_max_length = mkOption {
        type = types.nullOr types.int;
        description = "Maximum length in seconds for IOPS.";
        example = 60;
        default = null;
      };
      iops_rd = mkOption {
        type = types.nullOr types.str;
        description = "Read IOPS rate.";
        example = "500";
        default = null;
      };
      iops_rd_max = mkOption {
        type = types.nullOr types.str;
        description = "Maximum read IOPS rate.";
        example = "1000";
        default = null;
      };
      iops_rd_max_length = mkOption {
        type = types.nullOr types.int;
        description = "Maximum length in seconds for read IOPS.";
        example = 30;
        default = null;
      };
      iops_wr = mkOption {
        type = types.nullOr types.str;
        description = "Write IOPS rate.";
        example = "500";
        default = null;
      };
      iops_wr_max = mkOption {
        type = types.nullOr types.str;
        description = "Maximum write IOPS rate.";
        example = "1000";
        default = null;
      };
      iops_wr_max_length = mkOption {
        type = types.nullOr types.int;
        description = "Maximum length in seconds for write IOPS.";
        example = 30;
        default = null;
      };
      mbps = mkOption {
        type = types.nullOr types.str;
        description = "Megabytes per second rate.";
        example = "10M";
        default = null;
      };
      mbps_max = mkOption {
        type = types.nullOr types.str;
        description = "Maximum MBPS rate.";
        example = "20M";
        default = null;
      };
      mbps_rd = mkOption {
        type = types.nullOr types.str;
        description = "Read MBPS rate.";
        example = "5M";
        default = null;
      };
      mbps_rd_max = mkOption {
        type = types.nullOr types.str;
        description = "Maximum read MBPS rate.";
        example = "10M";
        default = null;
      };
      mbps_wr = mkOption {
        type = types.nullOr types.str;
        description = "Write MBPS rate.";
        example = "5M";
        default = null;
      };
      mbps_wr_max = mkOption {
        type = types.nullOr types.str;
        description = "Maximum write MBPS rate.";
        example = "10M";
        default = null;
      };
      media = mkOption {
        type = types.nullOr types.str;
        description = "Media type.";
        example = "disk";
        default = null;
      };
      model = mkOption {
        type = types.nullOr types.str;
        description = "Model name.";
        example = "virtio";
        default = null;
      };
      replicate = mkOption {
        type = types.nullOr types.bool;
        description = "Whether to replicate.";
        example = false;
        default = null;
      };
      rerror = mkOption {
        type = types.nullOr types.str;
        description = "Read error handling.";
        example = "report";
        default = null;
      };
      secs = mkOption {
        type = types.nullOr types.int;
        description = "Number of seconds.";
        example = 120;
        default = null;
      };
      serial = mkOption {
        type = types.nullOr types.str;
        description = "Serial number.";
        example = "123456789";
        default = null;
      };
      shared = mkOption {
        type = types.nullOr types.bool;
        description = "Whether the volume is shared.";
        example = false;
        default = null;
      };
      size = mkOption {
        type = types.nullOr types.str;
        description = "Disk size.";
        example = "10G";
        default = null;
      };
      snapshot = mkOption {
        type = types.nullOr types.bool;
        description = "Whether to enable snapshots.";
        example = true;
        default = null;
      };
      ssd = mkOption {
        type = types.nullOr types.bool;
        description = "Whether the disk is SSD.";
        example = true;
        default = null;
      };
      trans = mkOption {
        type = types.nullOr types.str;
        description = "Translation mode.";
        example = "auto";
        default = null;
      };
      werror = mkOption {
        type = types.nullOr types.str;
        description = "Write error handling.";
        example = "stop";
        default = null;
      };
      wwn = mkOption {
        type = types.nullOr types.str;
        description = "World Wide Name (WWN).";
        example = "12345678-1234-1234-1234-1234567890ab";
        default = null;
      };
    };
  };
in

{
  meta.maintainers = with maintainers; [
    julienmalka
    camillemndn
  ];

  options = {
    vmid = mkOption {
      type = types.nullOr (types.ints.between 100 999999999);
      default = null;
      description = "The (unique) ID of the VM.";
    };

    acpi = mkOption {
      type = types.nullOr types.bool;
      default = true;
      description = "Enable/disable ACPI.";
    };

    affinity = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "List of host cores used to execute guest processes.";
      example = "0,5,8-11";
    };

    agent = mkOption {
      type = types.nullOr (
        types.submodule {
          options = {
            enabled = mkEnableOption "Enable or disable communication with the QEMU Guest Agent.";
            freeze_fs_on_backup = mkEnableOption "Freeze file systems on backup.";
            fstrim_cloned_disks = mkEnableOption "Enable or disable fstrim on cloned disks.";
            type = mkOption {
              type = types.enum [
                "virtio"
                "isa"
              ];
              default = "virtio";
              description = "Specify the type of QEMU Guest Agent device.";
            };
          };
        }
      );
      default = null;
      description = "Enable/disable communication with the QEMU Guest Agent and its properties.";
    };

    arch = mkOption {
      type = types.nullOr (
        types.enum [
          "x86_64"
          "aarch64"
        ]
      );
      default = null;
      description = "Virtual processor architecture. Defaults to the host.";
    };

    archive = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The backup archive. Either the file system path to a .tar or .vma file or a proxmox storage backup volume identifier.";
    };

    args = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Arbitrary arguments passed to kvm. This option is for experts only.";
      example = "-no-reboot -smbios 'type=0,vendor=FOO'";
    };

    audio0 = mkOption {
      type = types.nullOr (
        types.submodule {
          options = {
            device = mkOption {
              type = types.enum [
                "ich9-intel-hda"
                "intel-hda"
                "AC97"
              ];
              default = "ich9-intel-hda";
              description = "Specify the type of audio device to be used.";
            };
            driver = mkOption {
              type = types.enum [
                "spice"
                "none"
              ];
              default = "none";
              description = "Specify the audio driver to be used.";
            };
          };
        }
      );
      default = null;
      description = "Configure an audio device, useful in combination with QXL/Spice.";
    };

    autostart = mkEnableOption "Automatic restart after crash (currently ignored).";

    balloon = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Amount of target RAM for the VM in MiB. Using zero disables the balloon driver.";
    };

    bios = mkOption {
      type = types.enum [
        "seabios"
        "ovmf"
      ];
      default = "seabios";
      description = "Select BIOS implementation.";
    };

    boot = mkOption {
      type = types.nullOr (
        types.submodule {
          options = {
            order = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Specify boot order of devices (e.g., 'disk', 'cdrom').";
            };
          };
        }
      );
      default = null;
      description = "Specify guest boot order.";
    };

    bwlimit = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Override I/O bandwidth limit (in KiB/s).";
    };

    cdrom = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Alias for option -ide2.";
    };

    cores = mkOption {
      type = types.int;
      default = 1;
      description = "The number of cores per socket.";
    };

    cpu = mkOption {
      type = types.nullOr (
        types.submodule {
          options = {
            cputype = mkOption {
              type = types.str;
              example = "host";
              description = "Specify the CPU type to emulate.";
            };
            flags = mkOption {
              type = types.str;
              example = "+vmx;-svm";
              description = "CPU flags to enable or disable.";
            };
            hidden = mkEnableOption "Whether to hide the CPU from the guest.";
            hv-vendor-id = mkOption {
              type = types.str;
              example = "MyHypervisor";
              description = "Hypervisor vendor ID string.";
            };
            phys-bits = mkOption {
              type = types.str;
              default = "host";
              example = "64";
              description = "Number of physical address bits to use (between 8 and 64) or 'host' to use host settings.";
            };
            reported-model = mkOption {
              type = types.str;
              example = "IvyBridge";
              description = "Reported CPU model string.";
            };
          };
        }
      );
      default = null;
      description = "Emulated CPU type.";
    };

    cpulimit = mkOption {
      type = types.ints.between 0 128;
      default = 0;
      description = ''
        Limit of CPU usage.
        NOTE: If the computer has 2 CPUs, it has total of '2' CPU time. Value '0' indicates no CPU limit.
      '';
    };

    cpuunits = mkOption {
      type = types.ints.between 1 262144;
      default = 1024;
      description = "CPU weight for a VM. The larger the number, the more CPU time this VM gets.";
    };

    description = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Description for the VM. Shown in the web-interface VM's summary.";
    };

    efidisk0 = mkOption {
      type = types.nullOr (
        types.submodule {
          options = {
            file = mkOption {
              type = types.str;
              example = "STORAGE_ID:10";
              description = ''
                Specify the volume for the disk.
                Use STORAGE_ID:SIZE_IN_GiB to allocate a new volume.
                Note that SIZE_IN_GiB is ignored here and that the default EFI vars are copied to the volume instead.
                Use STORAGE_ID:0 and the 'import-from' parameter to import from an existing volume.
              '';
            };
            efitype = mkOption {
              type = types.nullOr (
                types.enum [
                  "2m"
                  "4m"
                ]
              );
              default = "4m";
              example = "2m";
              description = "Specify the EFI vars disk size type.";
            };
            format = mkOption {
              type = types.nullOr types.str;
              example = "qcow2";
              default = null;
              description = "Specify the disk format.";
            };
            import-from = mkOption {
              type = types.nullOr types.str;
              example = "source-volume";
              default = null;
              description = "Specify the source volume to import from.";
            };
            pre-enrolled-keys = mkEnableOption "Whether to pre-enroll keys.";
            size = mkOption {
              type = types.nullOr types.str;
              example = "10GiB";
              default = null;
              description = "Specify the size of the disk. This parameter is ignored if 'file' specifies an EFI vars disk.";
            };
          };
        }
      );
      default = null;
      description = "Configure a disk for storing EFI vars.";
    };

    force = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Allow to overwrite existing VM.";
    };

    freeze = mkEnableOption "Freeze CPU at startup.";

    hookscript = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Script that will be executed during various steps in the VM's lifetime.";
    };

    hostpci = mkOption {
      type = types.nullOr (
        types.listOf (
          types.submodule {
            options = {
              host = mkOption {
                type = types.listOf types.str;
                example = [ "0000:00:1f.2" ];
                description = "Specify the host PCI IDs to map into the guest.";
              };
              device-id = mkOption {
                type = types.str;
                example = "1234";
                description = "Specify the device ID of the PCI device.";
              };
              legacy-igd = mkEnableOption "Enable or disable legacy integrated graphics device support.";
              mapping = mkOption {
                type = types.str;
                description = "Specify the mapping ID for the PCI device.";
              };
              mdev = mkOption {
                type = types.str;
                description = "Specify the mediated device for PCI passthrough.";
              };
              pcie = mkEnableOption "Enable or disable PCIe support for the device.";
              rombar = mkEnableOption "Enable or disable ROMBAR for the device.";
              romfile = mkOption {
                type = types.str;
                example = "/path/to/romfile.rom";
                description = "Specify the path to the ROM file for the device.";
              };
              sub-device-id = mkOption {
                type = types.str;
                example = "5678";
                description = "Specify the sub-device ID of the PCI device.";
              };
              sub-vendor-id = mkOption {
                type = types.str;
                example = "abcd";
                description = "Specify the sub-vendor ID of the PCI device.";
              };
              vendor-id = mkOption {
                type = types.str;
                example = "dead";
                description = "Specify the vendor ID of the PCI device.";
              };
              x-vga = mkEnableOption "Enable or disable VGA support for the PCI device.";
            };
          }
        )
      );
      default = null;
      description = ''
        Map host PCI devices into guest.

        NOTE: This option allows direct access to host hardware. So it is no longer
        possible to migrate such machines - use with special care.

        CAUTION: Experimental! User reported problems with this option.
      '';
    };

    hotplug = mkOption {
      type = types.either types.bool (
        types.listOf (
          types.enum [
            "network"
            "disk"
            "cpu"
            "memory"
            "usb"
            "cloudinit"
          ]
        )
      );
      default = [
        "network"
        "disk"
        "usb"
      ];
      description = "Selectively enable hotplug features. Use 'false' to disable hotplug completely.";
    };

    hugepages = mkOption {
      type = types.nullOr (
        types.enum [
          "any"
          "2"
          "1024"
        ]
      );
      default = null;
      description = "Enable/disable hugepages memory.";
    };

    ide = mkOption {
      type = types.listOf (types.submodule commonVolumeOptions);
      default = [ ];
      description = "Use volume as IDE hard disk or CD-ROM.";
    };

    ivshmem = mkOption {
      type = types.nullOr (
        types.submodule {
          options = {
            size = mkOption {
              type = types.int;
              description = "Size of the shared memory in megabytes.";
            };

            name = mkOption {
              type = types.str;
              description = "Name for the shared memory region.";
              example = "vmshm1";
            };
          };
        }
      );
      description = "Inter-VM shared memory. Useful for direct communication between VMs, or to the host.";
      default = null;
    };

    keephugepages = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Use together with hugepages. If enabled, hugepages will not not be deleted after VM shutdown and can be used for subsequent starts.";
    };

    keyboard = mkOption {
      type = types.nullOr (
        types.enum [
          "de"
          "de-ch"
          "da"
          "en-gb"
          "en-us"
          "es"
          "fi"
          "fr"
          "fr-be"
          "fr-ca"
          "fr-ch"
          "hu"
          "is"
          "it"
          "ja"
          "lt"
          "mk"
          "nl"
          "no"
          "pl"
          "pt"
          "pt-br"
          "sv"
          "sl"
          "tr"
        ]
      );
      default = null;
      description = "Keyboard layout for VNC server. This option is generally not required and is often better handled from within the guest OS.";
    };

    kvm = mkOption {
      type = types.bool;
      default = true;
      description = "Enable/disable KVM hardware virtualization.";
    };

    live-restore = mkEnableOption "Start the VM immediately while importing or restoring in the background.";

    localtime = mkEnableOption "Set the real time clock (RTC) to local time.";

    lock = mkOption {
      type = types.nullOr (
        types.enum [
          "backup"
          "clone"
          "create"
          "migrate"
          "rollback"
          "snapshot"
          "snapshot-delete"
          "suspending"
          "suspended"
        ]
      );
      default = null;
      description = "Lock/unlock the VM.";
    };

    machine = mkOption {
      type = types.nullOr (
        types.submodule {
          options = {
            type = mkOption {
              type = types.str;
              description = "Specifies the QEMU machine type.";
              example = "pc-i440fx-6.0";
            };

            viommu = mkOption {
              type = types.enum [
                "intel"
                "virtio"
              ];
              description = "Specifies the IOMMU type for the QEMU machine.";
              example = "intel";
            };
          };
        }
      );
      description = "Specify the QEMU machine.";
      default = null;
    };

    memory = mkOption {
      type = types.int;
      description = "Specifies the current memory size in megabytes.";
      example = 2048;
    };

    migrate_downtime = mkOption {
      type = types.float;
      default = 0.1;
      description = "Set maximum tolerated downtime (in seconds) for migrations. Should the migration not be able to converge in the very end, because too much newly dirtied RAM needs to be transferred, the limit will be increased automatically step-by-step until migration can converge.";
    };

    migrate_speed = mkOption {
      type = types.int;
      default = 0;
      description = "Set maximum speed (in MB/s) for migrations. Value 0 is no limit.";
    };

    net = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            model = mkOption {
              type = types.enum [
                "e1000"
                "virtio"
                "rtl8139"
                "vmxnet3"
              ];
              description = "Specifies the network device model.";
              example = "virtio";
            };
            bridge = mkOption {
              type = types.str;
              description = "Specifies the bridge to which the network device will be connected.";
              example = "vmbr0";
            };
            firewall = mkOption {
              type = types.bool;
              default = true;
              description = "Enable or disable the firewall on this network device.";
            };
            link_down = mkEnableOption "Specifies whether the network link is down.";
            macaddr = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Specifies the MAC address for the network device.";
              example = "52:54:00:12:34:56";
            };
            mtu = mkOption {
              type = types.nullOr types.int;
              default = null;
              description = "Specifies the MTU (Maximum Transmission Unit) for the network device.";
              example = 1500;
            };
            queues = mkOption {
              type = types.nullOr types.int;
              default = null;
              description = "Specifies the number of queues for the network device.";
              example = 4;
            };
            rate = mkOption {
              type = types.nullOr types.float;
              default = null;
              description = "Specifies the network rate limit in Mbps.";
              example = 100.0;
            };
            tag = mkOption {
              type = types.nullOr types.int;
              default = null;
              description = "Specifies the VLAN tag ID.";
              example = 100;
            };
            trunks = mkOption {
              type = types.listOf types.int;
              default = [ ];
              description = "Specifies a list of VLAN IDs for trunking.";
              example = [
                100
                200
                300
              ];
            };
            custom_macaddr = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Specifies a custom MAC address for the network device.";
              example = "52:54:00:ab:cd:ef";
            };
          };
        }
      );
      default = [ ];
      description = "Specify network devices.";
    };

    numa = mkEnableOption "NUMA.";

    numa_config = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            cpus = mkOption {
              type = types.listOf types.str;
              description = "Specifies the CPU IDs or ranges of IDs to be associated with the NUMA node.";
              example = [
                "0-3"
                "5"
              ];
            };
            hostnodes = mkOption {
              type = types.str;
              description = "Specifies the host NUMA node IDs or ranges of IDs.";
              example = "0-1";
            };
            memory = mkOption {
              type = types.int;
              description = "Specifies the amount of memory (in MiB) to be allocated to the NUMA node.";
              example = 2048;
            };
            policy = mkOption {
              type = types.enum [
                "preferred"
                "bind"
                "interleave"
              ];
              description = "Specifies the NUMA memory policy.";
              example = "preferred";
            };
          };
        }
      );
      default = [ ];
      description = "NUMA topology.";
    };

    onboot = mkEnableOption "Specifies whether a VM will be started during system bootup.";

    ostype = mkOption {
      type = types.enum [
        "other"
        "l24"
        "l26"
      ];
      default = "l26";
      description = "Specify guest operating system.";
    };

    parallel = mkOption {
      type = types.listOf (types.strMatching "(/dev/parport[[:digit:]]+|/dev/usb/lp[[:digit:]]+)");
      default = [ ];
      example = [ "/dev/parport0" ];
      description = "Map host parallel devices.";
    };

    pool = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Map host parallel devices (up to 3).

        NOTE: This option allows direct access to host hardware. So it is no longer possible to migrate such
        machines - use with special care.

        CAUTION: Experimental! User reported problems with this option.
      '';
    };

    protection = mkEnableOption "Sets the protection flag of the VM. This will disable the remove VM and remove disk operations.";

    reboot = mkOption {
      type = types.bool;
      default = true;
      description = "Allow reboot. If set to 'false' the VM exit on reboot.";
    };

    rng0 = mkOption {
      type = types.submodule {
        options = {
          source = mkOption {
            type = types.nullOr (
              types.enum [
                "/dev/urandom"
                "/dev/random"
                "/dev/hwrng"
              ]
            );
            default = null;
            description = "Specifies the source of entropy for the VirtIO-based RNG device.";
            example = "/dev/urandom";
          };
          max_bytes = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Specifies the maximum number of bytes that can be consumed from the RNG source per period.";
            example = 1024;
          };
          period = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Specifies the period in milliseconds during which max_bytes can be consumed.";
            example = 1000;
          };
        };
      };
      default = { };
      description = "Configure a VirtIO-based Random Number Generator.";
    };

    sata = mkOption {
      type = types.listOf (types.submodule commonVolumeOptions);
      default = [ ];
      description = "Use volume as SATA hard disk or CD-ROM.";
    };

    scsi = mkOption {
      type = types.listOf (
        types.submodule {
          options = commonVolumeOptions.options // {
            iothread = mkOption {
              type = types.bool;
              default = true;
              description = "Enable or disable I/O threads.";
            };
            product = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Product name for the SCSI disk.";
            };
            queues = mkOption {
              type = types.nullOr types.int;
              default = null;
              description = "Number of SCSI queues.";
            };
            scsiblock = mkEnableOption "Enable or disable SCSI block mode.";
            ro = mkEnableOption "Enable or disable read-only mode.";
            vendor = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Vendor name for the SCSI disk.";
            };
          };
        }
      );
      default = [ ];
      description = "Use volume as SCSI hard disk or CD-ROM (up to 30).";
    };

    scsihw = mkOption {
      type = types.nullOr (
        types.enum [
          "lsi"
          "lsi53c810"
          "virtio-scsi-pci"
          "virtio-scsi-single"
          "megasas"
          "pvscsi"
        ]
      );
      default = "virtio-scsi-single";
      description = "SCSI controller model.";
    };

    serial = mkOption {
      type = types.listOf (types.strMatching "(/dev/.+|socket)");
      default = [ ];
      description = ''
        Create a serial device inside the VM (up to 3), and pass through a
        host serial device (i.e. /dev/ttyS0), or create a unix socket on the
        host side (use 'qm terminal' to open a terminal connection).

        NOTE: If you pass through a host serial device, it is no longer possible to migrate such machines -
        use with special care.

        CAUTION: Experimental! User reported problems with this option.
      '';
    };

    shares = mkOption {
      type = types.ints.between 0 50000;
      default = 1000;
      description = "Amount of memory shares for auto-ballooning. The larger the number is, the more memory this VM gets. Number is relative to weights of all other running VMs. Using zero disables auto-ballooning. Auto-ballooning is done by pvestatd.";
    };

    smbios1 = mkOption {
      type = types.submodule {
        options = {
          base64 = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = "Indicates whether the provided SMBIOS fields are Base64 encoded.";
          };
          family = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Specifies the family of the SMBIOS type 1 fields in Base64 encoded string.";
            example = "QmFzZTY0RmFtaWx5";
          };
          manufacturer = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Specifies the manufacturer of the SMBIOS type 1 fields in Base64 encoded string.";
            example = "QmFzZTY0TWFudWZhY3R1cmVy"; # Example encoded string
          };
          product = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Specifies the product name of the SMBIOS type 1 fields in Base64 encoded string.";
            example = "QmFzZTY0UHJvZHVjdA==";
          };
          serial = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Specifies the serial number of the SMBIOS type 1 fields in Base64 encoded string.";
            example = "U2VyaWFsTnVtYmVy";
          };
          sku = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Specifies the SKU number of the SMBIOS type 1 fields in Base64 encoded string.";
            example = "U0tVTnVtYmVy";
          };
          uuid = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Specifies the UUID for the SMBIOS type 1 fields.";
            example = "123e4567-e89b-12d3-a456-426614174000";
          };
          version = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Specifies the version of the SMBIOS type 1 fields in Base64 encoded string.";
            example = "VmVyc2lvbk5hbWU=";
          };
        };
      };
      default = { };
      description = "Specify SMBIOS type 1 fields.";
    };

    sockets = mkOption {
      type = types.int;
      default = 1;
      description = "Number of CPU sockets.";
    };

    spice_enhancements = mkOption {
      type = types.submodule {
        options = {
          foldersharing = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = "Enable or disable folder sharing through SPICE.";
          };
          videostreaming = mkOption {
            type = types.nullOr (
              types.enum [
                "off"
                "all"
                "filter"
              ]
            );
            default = null;
            description = "Configure video streaming options for SPICE.";
            example = "off";
          };
        };
      };
      default = { };
      description = "Configure additional enhancements for SPICE.";
    };

    start = mkOption {
      type = types.bool;
      default = true;
      description = "Start VM after it was created successfully.";
    };

    startdate = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Set the initial date of the real time clock. Valid format for date are:'now' or '2006-06-17T16:01:21' or '2006-06-17'.";
    };

    startup = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Startup and shutdown behavior.";
    };

    storage = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default storage ID.";
    };

    tablet = mkOption {
      type = types.bool;
      default = true;
      description = "Enable/disable the USB tablet device. This device is usually needed to allow absolute mouse positioning with VNC. Else the mouse runs out of sync with normal VNC clients. If you're running lots of console-only guests on one host, you may consider disabling this to save some context switches. This is turned off by default if you use spice (`qm set <vmid> --vga qxl`).";
    };

    tags = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Tags of the VM. Tags are only meta information.";
    };

    tdf = mkEnableOption "time drift fix.";

    template = mkEnableOption "Template.";

    tpmstate0 = mkOption {
      type = types.submodule {
        options = {
          file = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Specify the volume for storing TPM state. Use STORAGE_ID:SIZE_IN_GiB to allocate a new volume. Note that SIZE_IN_GiB is ignored here and 4 MiB will be used instead. Use STORAGE_ID:0 and the 'import-from' parameter to import from an existing volume.";
            example = "STORAGE_ID:0";
          };
          import-from = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Specify the source volume to import TPM state from.";
          };
          version = mkOption {
            type = types.nullOr (
              types.enum [
                "v1.2"
                "v2.0"
              ]
            );
            default = null;
            description = "Specify the version of the TPM state.";
          };
        };
      };
      default = { };
      description = "Configure a Disk for storing TPM state. The format is fixed to 'raw'.";
    };

    unique = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Assign a unique random ethernet address.";
    };

    usb = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            host = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Specify the USB device or SPICE to be configured.";
              example = "/dev/bus/usb/001/002";
            };
            mapping = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Specify the mapping ID for the USB device.";
            };
            usb3 = mkOption {
              type = types.bool;
              default = true;
              description = "Enable or disable USB 3.0 support.";
            };
          };
        }
      );
      default = [ ];
      description = "Configure an USB device (up to 4).";
    };

    vga = mkOption {
      type = types.submodule {
        options = {
          type = mkOption {
            type = types.nullOr (
              types.enum [
                "cirrus"
                "std"
                "vmware"
                "qxl"
                "virtio"
                "none"
              ]
            );
            default = null;
            description = "Specify the type of VGA hardware.";
            example = "std";
          };
          clipboard = mkOption {
            type = types.enum [ "vnc" ];
            default = "vnc";
            description = "Enable clipboard sharing for VNC.";
          };
          memory = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Specify the amount of VGA memory in MiB.";
            example = 16;
          };
        };
      };
      default = { };
      description = "Configure the VGA Hardware.";
    };

    virtio = mkOption {
      type = types.listOf (
        types.submodule {
          options = commonVolumeOptions.options // {
            iothread = mkOption {
              type = types.bool;
              default = true;
              description = "Enable or disable I/O threads.";
            };
            ro = mkEnableOption "Enable or disable read-only mode.";
          };
        }
      );
      default = [ ];
      description = "Use volume as VIRTIO hard disk.";
    };

    vmgenid = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Virtual Machine Generation Identifier.";
    };

    vmstatestorage = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Reference to the volume storing the VM state. This is used internally.";
    };

    watchdog = mkOption {
      type = types.submodule {
        options = {
          model = mkOption {
            type = types.nullOr (
              types.enum [
                "i6300esb"
                "ib700"
              ]
            );
            default = null;
            description = "Specify the model of the virtual hardware watchdog device.";
            example = "i6300esb";
          };
          action = mkOption {
            type = types.nullOr (
              types.enum [
                "reset"
                "shutdown"
                "poweroff"
                "pause"
                "debug"
                "none"
              ]
            );
            default = null;
            description = "Specify the action to be taken if the watchdog is not polled by the guest.";
            example = "reset";
          };
        };
      };
      default = { };
      description = "Create a virtual hardware watchdog device.";
    };
  };

}
