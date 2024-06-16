{
  lib,
  stdenv,
  fetchgit,
  libvncserver,
  gnutls,
  libjpeg,
  libnsl,
  libpng,
}:

stdenv.mkDerivation rec {
  pname = "vncterm";
  version = "1.8.0";

  src = fetchgit {
    url = "https://git.proxmox.com/git/vncterm.git";
    rev = "6ceee68be1ffb58db99b2027bd6d7cb408b4cabc";
    hash = "sha256-HD6d6uEzG5u0EgrcmHg5N/mxofG0i1ZwpOB5E1G3In0=";
  };

  postPatch = ''
    sed -i Makefile \
      -e "/architecture.mk/d" \
      -e "/pkg-info/d" \
      -e "s|/usr/share/unifont/unifont.hex|${./unifont.hex}|" \
      -e "s|usr/||g" \
      -e "s/Werror/Wno-error/" \
      -e "s|wchardata.c|${./wchardata.c}|g" \
      -e "/^\$(VNCLIB)/,5d" \
      -e "/pod2man/d" \
      -e "/man1/d"

    sed -i vncterm.c -e "s|/usr|$out|"
  '';

  makeFlags =
    let
      libvncserver-patched = libvncserver.overrideAttrs (
        _: old: { patches = [ "${src}/vncpatches/tls-auth-pluging.patch" ]; }
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

  passthru.updateScript = [
    ../update.sh
    pname
    src.url
  ];

  meta = with lib; {
    description = "";
    homepage = "https://git.proxmox.com/git/vncterm.git";
    license = with licenses; [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    mainProgram = "vncterm";
    platforms = platforms.all;
  };
}
