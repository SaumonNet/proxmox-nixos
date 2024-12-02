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
    version = "3.3.2";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "94d38f0aba67ad04bf20159f605d5f7380cf7b58";
      hash = "sha256-wCPCEx8SpGpcuYDV2InobN9bcBu0RUlzcpD6sgmm/Wg=";
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
