To update, run:

```bash
# All and commit:
nix-shell tasks/update.nix --arg predicate '_: _: true' --argstr commit true

# Only Proxmox packages:
nix-shell tasks/update.nix --arg predicate '_: pkg: builtins.match ".*proxmox.*" pkg.src.url == []'

# Only Perl packages:
nix-shell tasks/update.nix --arg predicate '_: pkg: builtins.match ".*cpan.*" pkg.src.url == []'
```
