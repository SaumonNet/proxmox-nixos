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
  version = "4.2.3";

  src = fetchgit {
    url = "https://git.proxmox.com/git/proxmox-widget-toolkit.git";
    rev = "1ed4b715bc502fe1e0e8c4110083e9d6a14267ac";
    hash = "sha256-1T1Y0AOb1372PQrpuWeixJZeSHaKcEFlqXfz+gmUhcs=";
  };

  sourceRoot = "${src.name}/src";

  postPatch = ''
    sed -i defines.mk -e "s,/usr,,"
    sed -i Makefile -e "/BUILD_VERSION=/d" -e "/ESLINT/d"
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
    ../update.sh
    pname
    src.url
  ];

  meta = with lib; {
    description = "";
    homepage = "https://git.proxmox.com/git/proxmox-widget-toolkit.git";
    license = with licenses; [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
