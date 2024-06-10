{ lib
, stdenv
, fetchgit
, perl
, unzip
}:

let
  perlDeps = with perl.pkgs; with callPackage ../perl-packages.nix { }; [ AnyEventHTTP ];
in

perl.pkgs.toPerlModule (stdenv.mkDerivation rec {
  pname = "pve-http-server";
  version = "5.0.4";

  src = fetchgit {
    url = "https://git.proxmox.com/git/${pname}.git";
    rev = "6b09edd884e6d66dce153ccb2a33c8aab1436b29";
    hash = "sha256-UTmhA9+LmQNL2uoNC3QFxXx4YlEUDRS3zWXOUhlW1Ck=";
  };

  sourceRoot = "source/src";
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
    maintainers = with maintainers; [ camillemndn julienmalka ];
    platforms = platforms.linux;
  };
})
