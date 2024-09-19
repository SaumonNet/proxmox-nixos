{
  novnc,
  esbuild,
  fetchgit,
}:

novnc.overrideAttrs (old: rec {
  src_patches = fetchgit {
    url = "git://git.proxmox.com/git/novnc-pve.git";
    hash = "sha256-BQm4hDC7b+YaFipVonzcwVG/4JswkMSFZEpVkCdfrjM=";
  };

  patches =
    let
      series = builtins.readFile "${src_patches}/debian/patches/series";
      patchList = builtins.filter (patch: builtins.isString patch && patch != "") (
        builtins.split "\n" series
      );
      patchPathsList = map (patch: "${src_patches}/debian/patches/${patch}") patchList;
    in
    old.patches ++ patchPathsList;

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
})
