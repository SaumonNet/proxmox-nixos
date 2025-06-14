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
  version = "4.3.11";

  src = fetchgit {
    url = "git://git.proxmox.com/git/proxmox-widget-toolkit.git";
    rev = "91c5babc280df775f84fead9126c30774265f961";
    hash = "sha256-YkCDmAF/YsKMXw1JhVTEaHfF8eZB17heKbl6Ye/JG5o=";
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
    ../update.py
    pname
    "--url"
    src.url
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
