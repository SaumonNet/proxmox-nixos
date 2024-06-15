{ lib
, stdenv
, fetchgit
, markedjs
, nodePackages
, sassc
}:

stdenv.mkDerivation rec {
  pname = "proxmox-widget-toolkit";
  version = "4.0.6";

  src = fetchgit {
    url = "https://git.proxmox.com/git/proxmox-widget-toolkit.git";
    rev = "81562cea8dbc90f31b625847afb3dca6d43197bb";
    hash = "sha256-EE1jc2ZXXZ9CXfhyTQ05sjDqwv4sF2WanMepTZQ/lLE=";
  };

  sourceRoot = "${src.name}/src";

  postPatch = ''
    sed -i defines.mk -e "s,/usr,,"
    sed -i Makefile -e "/BUILD_VERSION=/d" -e "/ESLINT/d"
  '';

  buildInputs = [ nodePackages.uglify-js sassc ];

  makeFlags = [
    "DESTDIR=$(out)"
    "MARKEDJS=${markedjs}/lib/node_modules/marked/src/marked.js"
  ];

  postInstall = ''
    cp api-viewer/APIViewer.js $out/share/javascript/proxmox-widget-toolkit
  '';

  meta = with lib; {
    description = "";
    homepage = "https://git.proxmox.com/git/proxmox-widget-toolkit.git";
    license = with licenses; [ ];
    maintainers = with maintainers; [ camillemndn julienmalka ];
    platforms = platforms.linux;
  };
}
