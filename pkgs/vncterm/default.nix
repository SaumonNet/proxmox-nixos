{
  lib,
  stdenv,
  fetchgit,
  unifont_hex,
  libvncserver,
  gnutls,
  libjpeg,
  libnsl,
  libpng,
  bashInteractive,
  pve-update-script,
}:

stdenv.mkDerivation rec {
  pname = "vncterm";
  version = "1.9.1";

  src = fetchgit {
    url = "git://git.proxmox.com/git/vncterm.git";
    rev = "de6a5507b053cf73f817ba2822028c69ec60d557";
    hash = "sha256-XQtYOAOCZvLzFJQGWfARGrMSR2KVhKLN//LDOrTryW4=";
  };

  postPatch = ''
    sed -i Makefile \
      -e "/architecture.mk/d" \
      -e "/pkg-info/d" \
      -e "s|/usr/share/unifont/unifont.hex|${unifont_hex}/share/unifont/unifont.hex|" \
      -e "s|usr/||g" \
      -e "s/Werror/Wno-error/" \
      -e "s|wchardata.c|${unifont_hex}/share/unifont/wchardata.c|g" \
      -e "/^\$(VNCLIB)/,5d" \
      -e "/pod2man/d" \
      -e "/man1/d"

    sed -i vncterm.c -e "s|/usr|$out|"
    sed "s|/bin/bash|${bashInteractive}/bin/bash|g" -i vncterm.c
  '';

  makeFlags =
    let
      libvncserver-patched = libvncserver.overrideAttrs (
        _: _: { patches = [ "${src}/vncpatches/tls-auth-pluging.patch" ]; }
      );
    in
    [
      "VNCLIB=${libvncserver-patched}/lib/libvncserver.so"
      "VNCDIR=${libvncserver-patched.dev}/include"
      "DESTDIR=$(out)"
    ];

  buildInputs = [
    gnutls
    libjpeg
    libnsl
    libpng
  ];

  passthru.updateScript = pve-update-script { };

  meta = with lib; {
    description = "";
    homepage = "https://git.proxmox.com/?p=vncterm.git";
    license = with licenses; [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    mainProgram = "vncterm";
    platforms = platforms.all;
  };
}
