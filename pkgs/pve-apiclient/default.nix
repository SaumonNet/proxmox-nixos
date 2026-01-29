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
    version = "3.4.2";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "a56152820da7d97b2c2b1f9dc56d4775db50ec20";
      hash = "sha256-sJr1x1/UlP0N986tOZ1NJSSXU526Rn3jwAv6p5B5Tw4=";
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
