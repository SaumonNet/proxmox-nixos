{
  lib,
  stdenv,
  fetchgit,
  perl538,
  proxmox-widget-toolkit,
  extjs,
  font-awesome_4,
  fonts-font-logos,
}:

let
  perlDeps = with perl538.pkgs; [ AnyEventHTTP ];
  fonts-font-awesome = font-awesome_4.overrideAttrs (
    _: _: {
      installPhase = ''
        mkdir -p $out/share/fonts-font-awesome
        cp -r css $out/share/fonts-font-awesome
        cp -r fonts $out/share/fonts-font-awesome
        cp -r less $out/share/fonts-font-awesome
      '';
    }
  );
in

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-http-server";
    version = "5.1.2";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "2ef480f66473fd090e9a2cb02773461349e54502";
      hash = "sha256-MsBGven0SCUMU0rcm2nFFCz2G5uSjcAlaLjZdIhS4aU=";
    };

    sourceRoot = "${src.name}/src";
    propagatedBuildInputs = perlDeps;
    makeFlags = [ "PERL5DIR=$(out)/${perl538.libPrefix}/${perl538.version}" ];

    postFixup = ''
      find $out -type f | xargs sed -i \
        -e "s|/usr/share/javascript|$out/share/javascript|"
       mkdir -p $out/share/javascript
      ln -s ${proxmox-widget-toolkit}/share/javascript/proxmox-widget-toolkit $out/share/javascript
      ln -s ${extjs}/share/javascript/extjs $out/share/javascript
      ln -s ${fonts-font-awesome}/share/fonts-font-awesome $out/share
      ln -s ${fonts-font-logos}/share/fonts-font-logos $out/share
    '';

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
    ];

    meta = with lib; {
      description = "Proxmox VE HTTP Server";
      homepage = "git://git.proxmox.com/?p=pve-http-server.git";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
