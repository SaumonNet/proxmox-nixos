{
  lib,
  stdenv,
  fetchgit,
  pve-update-script,
}:

stdenv.mkDerivation {
  pname = "pve-xtermjs";
  version = "6.0.0-1";

  src = fetchgit {
    url = "git://git.proxmox.com/git/pve-xtermjs.git";
    rev = "1209ea0d5bda89fec71484d09f784bd3b94fafaf";
    hash = "sha256-u3ag6SX/+Y9d0WNDVCOxIM2N5ea1Zonwj+rWU7JcER4=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/pve-xtermjs
    cp -r $src/xterm.js/src/* $out/share/pve-xtermjs/
    cd $out/share/pve-xtermjs
    mv index.html.hbs.in index.html.hbs
    mv index.html.tpl.in index.html.tpl
  '';

  passthru.updateScript = pve-update-script { };

  meta = with lib; {
    description = "xterm.js webclient";
    homepage = "https://git.proxmox.com/?p=pve-xtermjs.git";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
