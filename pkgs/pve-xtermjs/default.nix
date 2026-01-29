{
  lib,
  stdenv,
  fetchgit,
  pve-update-script,
}:

stdenv.mkDerivation {
  pname = "pve-xtermjs";
  version = "5.5.0-3";

  src = fetchgit {
    url = "git://git.proxmox.com/git/pve-xtermjs.git";
    rev = "222b38aa8f226146d236a7f5f82744d03a8557df";
    hash = "sha256-OunLO3sGkpF7nbB0pNP4zTcxT1xHR7j/J0ZaV7UJhug=";
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
