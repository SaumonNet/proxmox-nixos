{
  lib,
  stdenv,
  fetchgit,
  pve-update-script,
}:

stdenv.mkDerivation rec {
  pname = "extjs";
  version = "7.0.0-7";

  src = fetchgit {
    url = "git://git.proxmox.com/git/extjs.git";
    rev = "c2f5ea149686be50ad429406ad7f8cbadd242f96";
    hash = "sha256-yCBzdQ0wD93xyQd9j9zwBH/pXiGlu6nXJCQiMY6/77g=";
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

  passthru.updateScript = pve-update-script {
    extraArgs = [
      "--deb-name"
      "libjs-extjs"
      "--use-git-log"
    ];
  };

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
