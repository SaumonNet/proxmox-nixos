{ lib
, stdenv
, fetchgit
}:

stdenv.mkDerivation rec {
  pname = "vncterm";
  version = "1.8.0";

  src = fetchgit {
    url = "https://git.proxmox.com/git/vncterm.git";
    rev = "8112a4cf9d16ce672edcd8445e3180911ba33f25";
    hash = "sha256-4GlA+cEk+uDktF4coh1LvwOnrEFkiCI4n0dfS6seMvE=";
  };

  postPatch = ''
    sed -i Makefile \
      -e '/pkg-info/d' \
      -e '/architecture/d' \
      -e "s,/usr,,"
  '';

  makeFlags = [
    "DESTDIR=$(out)"
  ];

  meta = with lib; {
    description = "";
    homepage = "https://git.proxmox.com/git/vncterm.git";
    license = [ ]; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "vncterm";
    platforms = platforms.all;
  };
}
