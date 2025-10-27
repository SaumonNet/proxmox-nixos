{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation rec {
  pname = "sencha-touch";
  version = "2.4.2";

  src = fetchgit {
    url = "git://git.proxmox.com/git/sencha-touch.git";
    rev = "c4685c8425cee430dd9c3b496a14fcc35c550a62";
    hash = "sha256-ZlUXcszZbi9kSXxF39wLf7PBhJlGBSVN6NS+WACuXmM=";
  };

  sourceRoot = "${src.name}/src";
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/javascript/sencha-touch
    cp sencha-touch-all.js $out/share/javascript/sencha-touch
    cp sencha-touch-all-debug.js $out/share/javascript/sencha-touch

    mkdir -p $out/share/javascript/sencha-touch/resources/css
    cp -r resources/css/*.css $out/share/javascript/sencha-touch/resources/css

    mkdir -p $out/share/javascript/sencha-touch/resources/themes/images
    cp -r resources/themes/images/default/* $out/share/javascript/sencha-touch/resources/themes/images
  '';

  meta = with lib; {
    description = "";
    homepage = "https://git.proxmox.com/?p=sencha-touch.git";
    license = [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.all;
  };
}
