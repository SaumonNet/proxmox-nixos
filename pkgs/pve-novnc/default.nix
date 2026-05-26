{
  novnc,
  esbuild,
  fetchgit,
  pve-update-script,
}:

novnc.overrideAttrs (old: rec {
  pname = "pve-novnc";
  version = "1.7.0-1";

  src = fetchgit {
    url = "git://git.proxmox.com/git/novnc-pve.git";
    rev = "72710ef2b38841ddc8c9e438fdf9e6c97ae634b2";
    hash = "sha256-fKEuBbW3Su05otQMD0S4cSn6WYncm/JPYzRc/Ppqiig=";
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
