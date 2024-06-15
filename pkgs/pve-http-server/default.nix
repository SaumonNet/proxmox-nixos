{
  lib,
  stdenv,
  fetchgit,
  perl,
  unzip,
}:

let
  perlDeps = with perl.pkgs; [ AnyEventHTTP ];
in

perl.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-http-server";
    version = "5.1.0";

    src = fetchgit {
      url = "https://git.proxmox.com/git/${pname}.git";
      rev = "da8543517ef48516304426bc8225133f093f3413";
      hash = "sha256-6f4WqWnG2YA5GYbaojZdkZghTBfSECTw+lcrgNoAPZU=";
    };

    sourceRoot = "${src.name}/src";
    buildInputs = [ unzip ];
    propagatedBuildInputs = perlDeps;
    makeFlags = [ "PERL5DIR=$(out)/${perl.libPrefix}/${perl.version}" ];

    postFixup = ''
      find $out -type f | xargs sed -i \
        -e "s|/usr/share/javascript|$out/share/javascript|"
      unzip ${./javascript.zip} -d $out/share
      unzip ${./fonts-font-awesome.zip} -d $out/share
    '';

    meta = with lib; {
      description = "";
      homepage = "https://github.com/proxmox/pve-http-server";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
