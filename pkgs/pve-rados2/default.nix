{
  lib,
  stdenv,
  fetchgit,
  perl536,
  ceph,
}:

perl536.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-rados2";
    version = "1.4.0";

    src = fetchgit {
      url = "https://git.proxmox.com/git/librados2-perl.git";
      rev = "c2e12db6baa0b302fbaf68dd619362144452829f";
      hash = "sha256-fiCUC+jgSAiaiS5a3xpaaPpAjyp3Y1afZKZLMuB4KZA=";
    };

    postPatch = ''
      sed -i Makefile \
        -e '/GITVERSION/d' \
        -e '/pkg-info/d' \
        -e '/architecture/d'
    '';

    buildInputs = [
      perl536
      ceph.dev
    ];

    makeFlags = [
      "DESTDIR=$(out)"
      "PREFIX="
      "SBINDIR=/bin"
      "PERLDIR=/${perl536.libPrefix}/${perl536.version}"
      "PERLSODIR=/${perl536.libPrefix}/auto"
    ];

    passthru.updateScript = [
      ../update.sh
      pname
      src.url
    ];

    meta = with lib; {
      description = "";
      homepage = "https://git.proxmox.com/git/librados2-perl536.git";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
