{
  lib,
  novnc,
  esbuild,
  fetchgit,
}:

novnc.overrideAttrs (old: rec {
  pname = "pve-novnc";
  version = "1.5.0-1";

  src = fetchgit {
    url = "git://git.proxmox.com/git/novnc-pve.git";
    rev = "2de2bef9737032c14edf0862261e34da74adb76d";
    hash = "sha256-5pybuOkvNVcP+In03ZokNpqgmGwB4DQEO4jmefV7W9Y=";
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

  installPhase =
    ''
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
    "--url"
    src.url
    "--version-prefix"
    (lib.versions.majorMinor old.version)
  ];

  meta.position = builtins.dirOf ./.;
})
