{
  lib,
  stdenv,
  fetchgit,
  perl538,
  dtach,
  lxc,
  openssh,
  tzdata,
}:

let
  perlDeps = [ ];
  perlEnv = perl538.withPackages (_: perlDeps);
in

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-container";
    version = "5.2.6";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "a0a7cec91c6f57c4ca3b6317ff12a15d2c528177";
      hash = "sha256-n0LR/DCziTYX7hvyptcyoKoZ9GtLncczLUXYeo4pZjQ=";
    };

    sourceRoot = "${src.name}/src";

    postPatch = ''
      sed -i Makefile \
        -e "s/pct.1 pct.conf.5 pct.bash-completion pct.zsh-completion //" \
        -e "s,/usr/share/lxc,$NIX_BUILD_TOP/lxc," \
        -e "/pve-doc-generator/d" \
        -e "/PVE_GENERATING_DOCS/d" \
        -e "/SERVICEDIR/d" \
        -e "/BASHCOMPLDIR/d" \
        -e "/ZSHCOMPLDIR/d" \
        -e "/MAN1DIR/d" \
        -e "/MAN5DIR/d"
    '';

    buildInputs = [ perlEnv ];
    propagatedBuildInputs = perlDeps;
    dontPatchShebangs = true;

    postConfigure = ''
      cp -r ${lxc}/share/lxc $NIX_BUILD_TOP/
      chmod -R +w $NIX_BUILD_TOP/lxc
    '';

    makeFlags = [
      "DESTDIR=$(out)"
      "PREFIX=$(out)"
      "SBINDIR=$(out)/.bin"
      "PERLDIR=$(out)/${perl538.libPrefix}/${perl538.version}"
    ];

    postFixup = ''
      find $out -type f | xargs sed -i \
        -e "s|/usr/bin/dtach|${dtach}/bin/dtach|" \
        -e "s|/usr/bin/ssh|${openssh}/bin/ssh|" \
        -e "s|/usr/bin/vncterm||" \
        -e "s|/usr/bin/termproxy||" \
        -e "s|/usr/bin/lxc|${lxc}/bin/lxc|" \
        -e "s|/usr/share/lxc|$out/share/lxc|" \
        -e "s|/usr/share/zoneinfo|${tzdata}/share/zoneinfo|"
    '';

    passthru.updateScript = [
      ../update.py
      pname
    ];

    meta = with lib; {
      description = "Proxmox VE container manager & runtime";
      homepage = "git://git.proxmox.com/?p=pve-container.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
