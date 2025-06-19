{
  lib,
  stdenv,
  fetchgit,
  perl538,
}:

let
  perlDeps = with perl538.pkgs; [ IOSocketSSL ];
in

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-apiclient";
    version = "3.4.0";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "6138da4f9d2e96db4a809fd8d4927dec43f8a9f9";
      hash = "sha256-2Dg364G2M8tBPPWSF2w2Ebz8UahYdopslyqqNWuLYVY=";
    };

    sourceRoot = "${src.name}/src";

    makeFlags = [
      "PERL5DIR=$(out)/${perl538.libPrefix}/${perl538.version}"
      "DOCDIR=$(out)/share/doc"
    ];

    propagatedBuildInputs = perlDeps;

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
    ];

    meta = with lib; {
      description = "Perl API client library";
      homepage = "git://git.proxmox.com/?p=pve-apiclient.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
