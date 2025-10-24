{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation rec {
  pname = "extjs";
  version = "7.0.0-5";

  src = fetchgit {
    url = "git://git.proxmox.com/git/extjs.git";
    rev = "18909118c3d316f0bb48846920b8c94a4efc31f5";
    hash = "sha256-AaV2DY5DG7tnqDFmfM3yIvJiyQYpR3pX9geH64JG4Ik=";
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
    "--deb-name"
    "libjs-extjs"
    "--use-git-log"
  ];

  meta = with lib; {
    description = "";
    homepage = "git://git.proxmox.com/?p=extjs.git";
    license = [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    mainProgram = "extjs";
    platforms = platforms.all;
  };
}
