{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation rec {
  pname = "pve-xtermjs";
  version = "5.3.0-3";

  src = fetchgit {
    url = "https://git.proxmox.com/git/pve-xtermjs.git";
    rev = "9e209b042bad4f3cf524654c1484ec8061a9edfb";
    hash = "sha256-Ifnv0sYC9nNHuHPpXwTn+2vKSFHpnFn1Gwc59s5kzOE=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/pve-xtermjs
    cp -r $src/xterm.js/src/* $out/share/pve-xtermjs/
    cd $out/share/pve-xtermjs
    mv index.html.hbs.in index.html.hbs
    mv index.html.tpl.in index.html.tpl
  '';

  passthru.updateScript = [
    ../update.sh
    pname
    src.url
    "xtermjs: bump version to"
    "xterm.js"
  ];

  meta = with lib; {
    description = "";
    homepage = "git://git.proxmox.com/git/proxmox-acme.git";
    license = with licenses; [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
