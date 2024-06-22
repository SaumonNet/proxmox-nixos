{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation rec {
  pname = "fonts-font-logos";
  version = "1.0.1-3";

  src = fetchgit {
    url = "https://git.proxmox.com/git/fonts-font-logos.git";
    rev = "063091d1a7ea70eba36c5684d20428ba215cb769";
    hash = "sha256-eSlnOqbXFLLlomFCb6IWdgzHAqqHn4sSTG5rEC4Tasg=";
  };

  sourceRoot = "${src.name}/src";

  installPhase = ''
    mkdir -p $out/share/fonts-font-logos/css
    cp -r font-logos/assets $out/share/fonts-font-logos/fonts
    cp font-logos.css $out/share/fonts-font-logos/css
  '';

  passthru.updateScript = [
    ../update.py
    pname
    "--url"
    src.url
  ];

  meta = with lib; {
    description = "";
    homepage = "https://git.proxmox.com/?p=fonts-font-logos.git";
    license = [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    mainProgram = "fonts-font-logos";
    platforms = platforms.all;
  };
}
