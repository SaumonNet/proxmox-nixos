{
  lib,
  stdenv,
  fetchgit,
  perl538,
  pve-update-script,
}:

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-guest-common";
    version = "6.0.2";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "73531017bfedda96176521e04cfe2c39138cf638";
      hash = "sha256-NxoDEv8aKdI3W6Wv2/AMwRg4ZtNlGUmqOi+/K1sAn9c=";
    };

    sourceRoot = "${src.name}/src";

    makeFlags = [
      "PERL5DIR=$(out)/${perl538.libPrefix}/${perl538.version}"
      "DOCDIR=$(out)/share/doc/${pname}"
    ];

    passthru.updateScript = pve-update-script {
      extraArgs = [
        "--deb-name"
        "libpve-guest-common-perl"
        "--use-git-log"
      ];
    };

    meta = with lib; {
      description = "Proxmox VE guest-related modules";
      homepage = "https://git.proxmox.com/?p=pve-guest-common.git";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
