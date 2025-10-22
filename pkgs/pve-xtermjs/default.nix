{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation rec {
  pname = "pve-xtermjs";
  version = "5.5.0-2";

  src = fetchgit {
    url = "git://git.proxmox.com/git/pve-xtermjs.git";
    rev = "a29b36079fbaf18586615e26bb615992d1007c7e";
    hash = "sha256-89K93D8uD1pAynM1M3ixbbZS3p7Sxga9OA/HgpVBeHY=";
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
    ../update.py
    pname
  ];

  meta = with lib; {
    description = "xterm.js webclient";
    homepage = "git://git.proxmox.com/?p=pve-xtermjs.git";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
