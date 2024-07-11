{
  novnc,
  esbuild,
  fetchgit,
}:

novnc.overrideAttrs (old: rec {
  src_patches = fetchgit {
    url = "https://git.proxmox.com/git/novnc-pve.git";
    hash = "sha256-5U2hSBNJVjG5/kkiEnicKOeEgVYmIJE0OIZRpslvXXg=";
  };

  src = fetchgit {
    url = "https://github.com/novnc/novnc";
    rev = "v1.4.0";
    hash = "sha256-G7Rtv7pQFR9UrzhYXDyBf+FRqtjo5NAXU7m/HeXhI1k=";
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
