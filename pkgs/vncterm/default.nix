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
  version = "1.9.2";

  src = fetchgit {
    url = "git://git.proxmox.com/git/vncterm.git";
    rev = "b8d28ad764934edf3f32721dcbbcfc301a5ded93";
    hash = "sha256-fmEiS2Nm3MU41HSpZED5fa+4PDeyOLDCr7I1SwFMrjw=";
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
