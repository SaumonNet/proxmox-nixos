{
  lib,
  stdenv,
  fetchgit,
  perl540,
  proxmox-i18n,
  proxmox-widget-toolkit,
  extjs,
  font-awesome_4,
  fonts-font-logos,
  pve-yew-mobile-gui,
  pve-update-script,
}:

let
  perlDeps = with perl540.pkgs; [ AnyEventHTTP ];
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

perl540.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-http-server";
    version = "6.0.5";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "5119ff9bec08c69584c0c98bea3edd0098179e5f";
      hash = "sha256-M3iNVq6nHOjBKoIuNhUmvWJp3lpX9mH5B+IXxbhtUxQ=";
    };

    sourceRoot = "${src.name}/src";
    propagatedBuildInputs = perlDeps;
    makeFlags = [ "PERL5DIR=$(out)/${perl540.libPrefix}/${perl540.version}" ];

    postFixup = ''
      find $out -type f | xargs sed -i \
        -e "s|/usr/share/javascript|$out/share/javascript|"
      mkdir -p $out/share/javascript
      ln -s ${proxmox-i18n}/share/pve-yew-mobile-i18n $out/share
      ln -s ${proxmox-widget-toolkit}/share/javascript/proxmox-widget-toolkit $out/share/javascript
      ln -s ${extjs}/share/javascript/extjs $out/share/javascript
      ln -s ${pve-yew-mobile-gui}/share/pve-yew-mobile-gui $out/share
      ln -s ${fonts-font-awesome}/share/fonts-font-awesome $out/share
      ln -s ${fonts-font-logos}/share/fonts-font-logos $out/share
    '';

    passthru.updateScript = pve-update-script {
      extraArgs = [
        "--deb-name"
        "libpve-http-server-perl"
      ];
    };

    meta = with lib; {
      description = "Proxmox VE HTTP Server";
      homepage = "https://git.proxmox.com/?p=pve-http-server.git";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
