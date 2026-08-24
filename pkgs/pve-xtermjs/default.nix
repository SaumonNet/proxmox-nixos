{
  lib,
  stdenv,
  fetchgit,
  pve-update-script,
}:

stdenv.mkDerivation {
  pname = "pve-xtermjs";
  version = "6.0.0-2";

  src = fetchgit {
    url = "git://git.proxmox.com/git/pve-xtermjs.git";
    rev = "89075b05773a2b6c380175dde3f8a4472a5ab506";
    hash = "sha256-lEQm/Lr3xXgklEoGEJ2VHLr6uZPO1thKR9ut/ZJ3+tg=";
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
