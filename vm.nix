{ config, lib, ... }:

with lib;

{
  meta.maintainers = with maintainers; [
    julienmalka
    camillemndn
  ];

  options.virtualisation.proxmox = {
    node = mkOption {
      type = types.str;
      description = "The cluster node name.";
    };

    vmid = mkOption {
      type = types.int;
      description = "The (unique) ID of the VM.";
    };

    name = mkOption {
      type = types.str;
      default = config.networking.hostName;
      description = "Set a name for the VM. Only used on the configuration web interface.";
    };

    acpi = mkOption {
      type = types.bool;
      default = true;
      description = "Enable/disable ACPI.";
    };

    affinity = mkOption {
      type = types.str;
      description = "List of host cores used to execute guest processes, e.g., 0,5,8-11.";
    };

    agent = mkOption {
      type = types.str;
      description = "Enable/disable communication with the QEMU Guest Agent and its properties.";
    };

    arch = mkOption {
      type = types.enum [
        "x86_64"
        "aarch64"
      ];
      description = "Virtual processor architecture. Defaults to the host.";
    };

    archive = mkOption {
      type = types.str;
      description = "The backup archive. Either the file system path to a .tar or .vma file or a proxmox storage backup volume identifier.";
    };

    args = mkOption {
      type = types.str;
      description = "Arbitrary arguments passed to kvm. This option is for experts only.";
    };

    audio0 = mkOption {
      type = types.str;
      description = "Configure an audio device, useful in combination with QXL/Spice.";
    };

    autostart = mkOption {
      type = types.bool;
      default = false;
      description = "Automatic restart after crash (currently ignored).";
    };

    balloon = mkOption {
      type = types.int;
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
      type = types.str;
      description = "Specify guest boot order.";
    };

    bootdisk = mkOption {
      type = types.str;
      description = "Enable booting from specified disk. Deprecated: Use 'boot: order=foo;bar' instead.";
    };

    bwlimit = mkOption {
      type = types.int;
      description = "Override I/O bandwidth limit (in KiB/s).";
    };

    cdrom = mkOption {
      type = types.str;
      description = "Alias for option -ide2.";
    };

    cicustom = mkOption {
      type = types.str;
      description = "Specify custom files to replace the automatically generated ones at start.";
    };

    cipassword = mkOption {
      type = types.str;
      description = "Cloud-init: Password to assign the user. Using SSH keys instead is recommended.";
    };

    citype = mkOption {
      type = types.enum [
        "configdrive2"
        "nocloud"
        "opennebula"
      ];
      description = "Specifies the cloud-init configuration format.";
    };

    ciupgrade = mkOption {
      type = types.bool;
      default = true;
      description = "Cloud-init: do an automatic package upgrade after the first boot.";
    };

    ciuser = mkOption {
      type = types.str;
      description = "Cloud-init: User name to change ssh keys and password for instead of the image's configured default user.";
    };

    cores = mkOption {
      type = types.int;
      default = 1;
      description = "The number of cores per socket.";
    };

    cpu = mkOption {
      type = types.str;
      description = "Emulated CPU type.";
    };

    cpulimit = mkOption {
      type = types.float;
      default = 0;
      description = "Limit of CPU usage.";
    };

    cpuunits = mkOption {
      type = types.int;
      default = 1024;
      description = "CPU weight for a VM. The larger the number, the more CPU time this VM gets.";
    };

    description = mkOption {
      type = types.str;
      description = "Description for the VM. Shown in the web-interface VM's summary.";
    };

    efidisk0 = mkOption {
      type = types.str;
      description = "Configure a disk for storing EFI vars.";
    };

    force = mkOption {
      type = types.bool;
      description = "Allow to overwrite existing VM.";
    };

    freeze = mkOption {
      type = types.bool;
      description = "Freeze CPU at startup.";
    };

    hookscript = mkOption {
      type = types.str;
      description = "Script that will be executed during various steps in the VM's lifetime.";
    };

    hostpci = mkOption {
      type = types.str;
      description = "Map host PCI devices into guest.";
    };

    hotplug = mkOption {
      type = types.str;
      default = "network,disk,usb";
      description = "Selectively enable hotplug features.";
    };

    hugepages = mkOption {
      type = types.enum [
        "any"
        "2"
        "1024"
      ];
      description = "Enable/disable hugepages memory.";
    };

    ide = mkOption {
      type = types.str;
      description = "Use volume as IDE hard disk or CD-ROM.";
    };

    ipconfig = mkOption {
      type = types.str;
      description = "Cloud-init: Specify IP addresses and gateways for the corresponding interface.";
    };

    ivshmem = mkOption {
      type = types.str;
      description = "Inter-VM shared memory. Useful for direct communication between VMs, or to the host.";
    };

    keephugepages = mkOption {
      type = types.bool;
      default = false;
      description = "If enabled, hugepages will not be deleted after VM shutdown.";
    };

    keyboard = mkOption {
      type = types.enum [
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
      ];
      description = "Keyboard layout for VNC server.";
    };

    kvm = mkOption {
      type = types.bool;
      default = true;
      description = "Enable/disable KVM hardware virtualization.";
    };

    live-restore = mkOption {
      type = types.bool;
      description = "Start the VM immediately while importing or restoring in the background.";
    };

    localtime = mkOption {
      type = types.bool;
      description = "Set the real time clock (RTC) to local time.";
    };

    lock = mkOption {
      type = types.enum [
        "backup"
        "clone"
        "create"
        "migrate"
        "rollback"
        "snapshot"
        "snapshot-delete"
        "suspending"
        "suspended"
      ];
      description = "Lock/unlock the VM.";
    };

    machine = mkOption {
      type = types.str;
      description = "Specify the QEMU machine.";
    };

    memory = mkOption {
      type = types.str;
      description = "Memory properties.";
    };

    migrate_downtime = mkOption {
      type = types.float;
      default = 0.1;
      description = "Set maximum tolerated downtime (in seconds) for migrations.";
    };

    migrate_speed = mkOption {
      type = types.int;
      default = 0;
      description = "Set maximum speed (in MB/s) for migrations.";
    };

    nameserver = mkOption {
      type = types.str;
      description = "Cloud-init: Sets DNS server IP address for a container.";
    };

    net = mkOption {
      type = types.str;
      description = "Specify network devices.";
    };

    numa = mkOption {
      type = types.bool;
      default = false;
      description = "Enable/disable NUMA.";
    };

    numa_config = mkOption {
      type = types.str;
      description = "NUMA topology.";
    };

    onboot = mkOption {
      type = types.bool;
      default = false;
      description = "Specifies whether a VM will be started during system bootup.";
    };

    ostype = mkOption {
      type = types.enum [
        "other"
        "wxp"
        "w2k"
        "w2k3"
        "w2k8"
        "wvista"
        "win7"
        "win8"
        "win10"
        "win11"
        "l24"
        "l26"
        "solaris"
      ];
      description = "Specify guest operating system.";
    };

    parallel = mkOption {
      type = types.str;
      description = "Map host parallel devices.";
    };

    pool = mkOption {
      type = types.str;
      description = "Add the VM to the specified pool.";
    };

    protection = mkOption {
      type = types.bool;
      default = false;
      description = "Sets the protection flag of the VM.";
    };

    reboot = mkOption {
      type = types.bool;
      default = true;
      description = "Allow reboot. If set to '0' the VM exit on reboot.";
    };

    rng0 = mkOption {
      type = types.str;
      description = "Configure a VirtIO-based Random Number Generator.";
    };

    sata = mkOption {
      type = types.str;
      description = "Use volume as SATA hard disk or CD-ROM.";
    };

    scsi = mkOption {
      type = types.str;
      description = "Use volume as SCSI hard disk or CD-ROM.";
    };

    searchdomain = mkOption {
      type = types.str;
      description = "Cloud-init: Sets DNS search domains for a container.";
    };

    serial = mkOption {
      type = types.str;
      description = "Create a serial device inside the VM.";
    };

    shares = mkOption {
      type = types.int;
      default = 1000;
      description = "Amount of CPU shares for a VM.";
    };

    skiplock = mkOption {
      type = types.bool;
      description = "Ignore locks, useful for debugging.";
    };

    smbios = mkOption {
      type = types.str;
      description = "Generate SMBIOS entries.";
    };

    smp = mkOption {
      type = types.str;
      description = "Number of CPUs. Deprecated: Use 'cores' instead.";
    };

    sockets = mkOption {
      type = types.int;
      default = 1;
      description = "Number of CPU sockets.";
    };

    spice_enhancements = mkOption {
      type = types.str;
      description = "Spice QXL enhancements.";
    };

    sshkeys = mkOption {
      type = types.str;
      description = "Cloud-init: Setup public SSH keys (one key per line).";
    };

    startdate = mkOption {
      type = types.str;
      description = "Initial date for the RTC.";
    };

    startup = mkOption {
      type = types.str;
      description = "Startup and shutdown behavior.";
    };

    storage = mkOption {
      type = types.str;
      description = "Default storage.";
    };

    tablet = mkOption {
      type = types.bool;
      description = "Enable/disable the USB tablet device.";
    };

    tags = mkOption {
      type = types.str;
      description = "Tags of the VM. Tags are only meta information.";
    };

    template = mkOption {
      type = types.bool;
      description = "Enable/disable template flag.";
    };

    tpmstate = mkOption {
      type = types.str;
      description = "Configure a TPM state storage.";
    };

    unique = mkOption {
      type = types.bool;
      default = false;
      description = "Assign a unique name to the VM.";
    };

    unused = mkOption {
      type = types.str;
      description = "Reference to unused volumes. This is used internally.";
    };

    usb = mkOption {
      type = types.str;
      description = "Configure an USB device (n = 0 to 4).";
    };

    vcpus = mkOption {
      type = types.int;
      description = "Number of hot-pluggable CPUs. Deprecated: Use 'cores' instead.";
    };

    vga = mkOption {
      type = types.str;
      description = "Configure a VGA device.";
    };

    virtio = mkOption {
      type = types.str;
      description = "Use volume as VIRTIO hard disk.";
    };

    vmgenid = mkOption {
      type = types.str;
      description = "Virtual Machine Generation Identifier.";
    };

    vmstate = mkOption {
      type = types.str;
      description = "Reference to the volume storing the VM state. This is used internally.";
    };

    watchdog = mkOption {
      type = types.str;
      description = "Create a virtual hardware watchdog device.";
    };
  };
}
