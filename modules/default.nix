{
  default = import ./proxmox-ve;
  proxmox-ve = import ./proxmox-ve;
  proxmox-backup = import ./proxmox-backup;
  rrdcached = import ./rrdcached.nix;
}
