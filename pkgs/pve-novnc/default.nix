{
  novnc,
  esbuild,
  fetchgit,
  pve-update-script,
}:

novnc.overrideAttrs (old: rec {
  pname = "pve-novnc";
  version = "1.7.0-2";

  src = fetchgit {
    url = "git://git.proxmox.com/git/novnc-pve.git";
    rev = "10ddb6126aa4991e55d1ad7652b2b011254f5a36";
    hash = "sha256-1S0JpZb5pTBFGUQ0tNg2oKLVs7Uc1vKVszzLstT2wLg=";
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
