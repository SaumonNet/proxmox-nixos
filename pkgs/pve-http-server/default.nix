{
  lib,
  stdenv,
  fetchgit,
  perl538,
  proxmox-widget-toolkit,
  extjs,
  font-awesome_4,
  fonts-font-logos,
  sencha-touch,
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
    version = "6.0.0";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "0cf78af09465e757a65f436c8bc60f235c5c243e";
      hash = "sha256-JXvCk4aISx0ZEyJfE9zdrxoh+uk+qosxQWiEKSM6LhE=";
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
      ln -s ${sencha-touch}/share/javascript/sencha-touch $out/share/javascript
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
