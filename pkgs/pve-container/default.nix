{
  lib,
  stdenv,
  fetchgit,
  perl,
  dtach,
  lxc,
  openssh,
  tzdata,
}:

let
  perlDeps = [ ];
  perlEnv = perl.withPackages (_: perlDeps);
in

perl.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-container";
    version = "5.1.11";

    src = fetchgit {
      url = "https://git.proxmox.com/git/${pname}.git";
      rev = "d08a6337632dcbb262d877bd9d880586104d49bb";
      hash = "sha256-dAo5y/UEvYFtM56x1VOTqKF1G+5T3RfefN1aYSjHZWo=";
    };

    sourceRoot = "${src.name}/src";

    postPatch = ''
      sed -i Makefile \
        -e "s/pct.1 pct.conf.5 pct.bash-completion pct.zsh-completion //" \
        -e "s,/usr/share/lxc,/build/lxc," \
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
      cp -r ${lxc}/share/lxc /build
      chmod -R +w /build/lxc
    '';

    makeFlags = [
      "DESTDIR=$(out)"
      "PREFIX=$(out)"
      "SBINDIR=$(out)/.bin"
      "PERLDIR=$(out)/${perl.libPrefix}/${perl.version}"
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

    meta = with lib; {
      description = "Proxmox VE container manager & runtime - read-only mirror";
      homepage = "https://github.com/proxmox/pve-container";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
