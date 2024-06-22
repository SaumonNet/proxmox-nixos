{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation rec {
  pname = "extjs";
  version = "7.0.0-4";

  src = fetchgit {
    url = "https://git.proxmox.com/git/extjs.git";
    rev = "c0c1b0b6335618415ada92f04bd35774e3edb856";
    hash = "sha256-WCVaXD8gabezcri2agtjfbx+2wt6knRJVBQeOv7OlxI=";
  };

  sourceRoot = "${src.name}/extjs/build";

  installPhase = ''
    mkdir -p $out/share/javascript/extjs
    cp -r classic/locale $out/share/javascript/extjs
    cp -r classic/theme-crisp $out/share/javascript/extjs
    cp ext-all-debug.js $out/share/javascript/extjs
    cp ext-all.js $out/share/javascript/extjs
    cp packages/charts/classic/charts-debug.js $out/share/javascript/extjs
    cp packages/charts/classic/charts.js $out/share/javascript/extjs
    cp -r packages/charts/classic/crisp $out/share/javascript/extjs
  '';

  passthru.updateScript = [
    ../update.py
    pname
    "--url"
    src.url
  ];

  meta = with lib; {
    description = "";
    homepage = "https://git.proxmox.com/?p=extjs.git";
    license = [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    mainProgram = "extjs";
    platforms = platforms.all;
  };
}
