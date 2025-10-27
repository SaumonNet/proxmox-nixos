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
  version = "1.8.1";

  src = fetchgit {
    url = "git://git.proxmox.com/git/vncterm.git";
    rev = "4a524cc2d2fce951c1cf071b62221fe99f20a290";
    hash = "sha256-VIaRpx+POFmryv2sA9I2ja+o+GO9kuioc0E7cSmMEXQ=";
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
    homepage = "git://git.proxmox.com/?p=vncterm.git";
    license = with licenses; [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    mainProgram = "vncterm";
    platforms = platforms.all;
  };
}
