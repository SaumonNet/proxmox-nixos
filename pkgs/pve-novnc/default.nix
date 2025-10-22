{
  lib,
  novnc,
  esbuild,
  fetchgit,
}:

novnc.overrideAttrs (old: rec {
  pname = "pve-novnc";
  version = "1.6.0-2";

  src = fetchgit {
    url = "git://git.proxmox.com/git/novnc-pve.git";
    rev = "87b1dc5c373427a03c56109332d5ee7cbd02468e";
    hash = "sha256-5ZmHezMZbJHAOlL7fbGYOD4WYIecyb5y+WfJcKnhtfU=";
    fetchSubmodules = true;
  };

  patches =
    let
      series = builtins.readFile "${src}/debian/patches/series";
      patchList = builtins.filter (patch: builtins.isString patch && patch != "") (
        builtins.split "\n" series
      );
      patchPathsList = map (patch: "${src}/debian/patches/${patch}") patchList;
    in
    old.patches ++ patchPathsList;

  sourceRoot = "${src.name}/novnc";

  buildInputs = [ esbuild ];

  installPhase = ''
    esbuild --bundle app/ui.js > app.js
  ''
  + old.installPhase
  + ''
    cp app.js $out/share/webapps/novnc/
    mv $out/share/webapps/novnc/{vnc.html,index.html.tpl}
  '';

  passthru.updateScript = [
    ../update.py
    pname
    "--deb-name"
    "novnc-pve"
  ];

  meta.position = builtins.dirOf ./.;
})
