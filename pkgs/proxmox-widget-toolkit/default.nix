{
  lib,
  stdenv,
  fetchgit,
  markedjs,
  nodePackages,
  sassc,
}:

stdenv.mkDerivation rec {
  pname = "proxmox-widget-toolkit";
  version = "4.3.13";

  src = fetchgit {
    url = "git://git.proxmox.com/git/proxmox-widget-toolkit.git";
    rev = "492daaf42584813748c6fcb0d1526b87d8550b60";
    hash = "sha256-MZq3nDSsd6OMMeNIv6RXohsF36fPxVLopGqw0V5AAA8=";
  };

  sourceRoot = "${src.name}/src";

  postPatch = ''
    sed -i defines.mk -e "s,/usr,,"
    sed -i Makefile -e "/BUILD_VERSION=/d" -e "/BIOME/d"
  '';

  buildInputs = [
    nodePackages.uglify-js
    sassc
  ];

  makeFlags = [
    "DESTDIR=$(out)"
    "MARKEDJS=${markedjs}/lib/node_modules/marked/marked.min.js"
  ];

  postInstall = ''
    cp api-viewer/APIViewer.js $out/share/javascript/proxmox-widget-toolkit
  '';

  passthru.updateScript = [
    ../update.py
    pname
  ];

  meta = with lib; {
    description = "";
    homepage = "git://git.proxmox.com/?p=proxmox-widget-toolkit.git";
    license = with licenses; [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
