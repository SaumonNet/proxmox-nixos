{
  lib,
  novnc,
  esbuild,
  fetchgit,
}:

novnc.overrideAttrs (old: rec {
  pname = "pve-novnc";
  version = "1.4.0-4";

  src = fetchgit {
    url = "git://git.proxmox.com/git/novnc-pve.git";
    rev = "e410ca0eea1d2ab9d3bf93db8e5e1c44cd8229fb";
    hash = "sha256-BQm4hDC7b+YaFipVonzcwVG/4JswkMSFZEpVkCdfrjM=";
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
