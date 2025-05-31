[
  {
    name = "librust-proxmox-io-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "c336cb9ab78b2bc3ebd9ab6a94e9e6f202de3ee6";

    sha256 = "1b8zl8by8rpz1bv6drq3pzpfqf98rj2yl91ldg1mgig3dmbck4db";
    crates = [
      {
        name = "proxmox-io";
        path = "proxmox-io";
      }
    ];
  }
  {
    name = "librust-proxmox-lang-dev";
    url = "git://git.proxmox.com/git/proxmox.git";
    rev = "d8eb6d1bde70a308190e14270b025d6c7270198d";

    sha256 = "sha256-LnBMxRY3ELf5ktP2in2fM9rXlqS7s2Xm+nhPktfSvhI=";
    crates = [
      {
        name = "proxmox-lang";
        path = "proxmox-lang";
      }
    ];
  }

]
