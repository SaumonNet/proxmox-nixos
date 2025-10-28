{
  lib,
  stdenv,
  fetchgit,
  perl540,
  pve-update-script,
}:

let
  perlDeps = with perl540.pkgs; [ IOSocketSSL ];
in

perl540.pkgs.toPerlModule (
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
      "PERL5DIR=$(out)/${perl540.libPrefix}/${perl540.version}"
      "DOCDIR=$(out)/share/doc"
    ];

    propagatedBuildInputs = perlDeps;

    passthru.updateScript = pve-update-script {
      extraArgs = [
        "--deb-name"
        "libpve-apiclient-perl"
      ];
    };

    meta = with lib; {
      description = "Perl API client library";
      homepage = "https://git.proxmox.com/?p=pve-apiclient.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
