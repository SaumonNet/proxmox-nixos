{
  lib,
  stdenv,
  fetchgit,
  perl538,
  ceph,
}:

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-rados2";
    version = "1.4.1";

    src = fetchgit {
      url = "git://git.proxmox.com/git/librados2-perl.git";
      rev = "b2017399cac82628e15ec14e95551c14fdfbf14f";
      hash = "sha256-rHBM4xVwxAO0ZOU9YVw/n98JBzyRDwm0sOEAOhzUARc=";
    };

    postPatch = ''
      sed -i Makefile \
        -e '/GITVERSION/d' \
        -e '/pkg-info/d' \
        -e '/architecture/d'
    '';

    buildInputs = [
      perl538
      ceph.dev
    ];

    makeFlags = [
      "DESTDIR=$(out)"
      "PREFIX="
      "SBINDIR=/bin"
      "PERLDIR=/${perl538.libPrefix}/${perl538.version}"
      "PERLSODIR=/${perl538.libPrefix}/auto"
    ];

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
    ];

    meta = with lib; {
      description = "Perl bindings for librados";
      homepage = "git://git.proxmox.com/?p=librados2-perl.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
