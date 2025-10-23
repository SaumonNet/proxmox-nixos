{
  lib,
  stdenv,
  fetchgit,
  perl538,
  ceph,
  pve-update-script,
}:

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation {
    pname = "pve-rados2";
    version = "1.5.0";

    src = fetchgit {
      url = "git://git.proxmox.com/git/librados2-perl.git";
      rev = "52544bb3b69bad74b4caf29698bb9ceb9a7bb6e0";
      hash = "sha256-CcURv6KrfdyzRq9ccOXita05QHJ9AdvZTTxPRWpO0k0=";
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

    passthru.updateScript = pve-update-script {
      extraArgs = [
        "--deb-name"
        "librados2-perl"
        "--use-git-log"
      ];
    };

    meta = with lib; {
      description = "Perl bindings for librados";
      homepage = "https://git.proxmox.com/?p=librados2-perl.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
