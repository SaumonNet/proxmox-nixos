# Proxmox on NixOS

![Proxmox on NixOS](proxmox-nixos.png)

To update, run:

```
# To update all:
nix-shell tasks/update.nix --arg predicate '_: _: true'

# To update only Proxmox packages:
nix-shell tasks/update.nix --arg predicate '_: pkg: builtins.match ".*proxmox.*" pkg.src.url == []'

# To update only Perl packages:
nix-shell tasks/update.nix --arg predicate '_: pkg: builtins.match ".*cpan.*" pkg.src.url == []'
```
