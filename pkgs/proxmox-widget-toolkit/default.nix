{
  lib,
  stdenv,
  fetchgit,
  markedjs,
  uglify-js,
  sassc,
  pve-update-script,
}:

stdenv.mkDerivation rec {
  pname = "proxmox-widget-toolkit";
  version = "5.2.2";

  src = fetchgit {
    url = "git://git.proxmox.com/git/proxmox-widget-toolkit.git";
    rev = "af42d9316e9e25768c3b5a99a91758aaa5b8e933";
    hash = "sha256-pTTe9RYUdie+iTFuV6uWIcHfnVE8f478F2eyYuP7NX8=";
  };

  sourceRoot = "${src.name}/src";

  postPatch = ''
    sed -i defines.mk -e "s,/usr,,"
    sed -i Makefile -e "/BUILD_VERSION=/d" -e "/BIOME/d"
  '';

  buildInputs = [
    uglify-js
    sassc
  ];

  makeFlags = [
    "DESTDIR=$(out)"
    "MARKEDJS=${markedjs}/lib/node_modules/marked/lib/marked.umd.js"
  ];

  postInstall = ''
    cp api-viewer/APIViewer.js $out/share/javascript/proxmox-widget-toolkit
  '';

  passthru.updateScript = pve-update-script { };

  meta = with lib; {
    description = "";
    homepage = "https://git.proxmox.com/?p=proxmox-widget-toolkit.git";
    license = with licenses; [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
