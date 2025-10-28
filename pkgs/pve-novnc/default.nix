{
  novnc,
  esbuild,
  fetchgit,
  pve-update-script,
}:

novnc.overrideAttrs (old: rec {
  pname = "pve-novnc";
  version = "1.6.0-3";

  src = fetchgit {
    url = "git://git.proxmox.com/git/novnc-pve.git";
    rev = "3d6c1bf3ba8bb7bb2aba3a6757b69ff8633f3b5c";
    hash = "sha256-uhyn8IOiyV72DL2USE2WUn5QDk4tVQiCx2VUaskTbGQ=";
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
    esbuild --bundle --format=esm app/ui.js > app.js
  ''
  + old.installPhase
  + ''
    cp app.js $out/share/webapps/novnc/
    mv $out/share/webapps/novnc/{vnc.html,index.html.tpl}
  '';

  passthru.updateScript = pve-update-script {
    extraArgs = [
      "--deb-name"
      "novnc-pve"
    ];
  };

  meta.position = builtins.dirOf ./.;
})
