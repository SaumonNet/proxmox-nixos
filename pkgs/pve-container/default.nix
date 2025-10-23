{
  lib,
  stdenv,
  fetchgit,
  perl538,
  dtach,
  lxc,
  openssh,
  tzdata,
  pve-update-script,
}:

let
  perlDeps = [ ];
  perlEnv = perl538.withPackages (_: perlDeps);
in

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-container";
    version = "6.0.13";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "ab898eb9f0280285976d02232094e5f6d0ae168d";
      hash = "sha256-MLvWrNwPdlvWlcqcQ8ZCsvw9rCkptHfHVZxlMYmjcXA=";
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
        -e "s|/bin/true|true|" \
        -e "s|/usr/bin/vncterm||" \
        -e "s|/usr/bin/termproxy||" \
        -e "s|/usr/bin/lxc|${lxc}/bin/lxc|" \
        -e "s|/usr/share/lxc|$out/share/lxc|" \
        -e "s|/usr/share/zoneinfo|${tzdata}/share/zoneinfo|"
    '';

    passthru.updateScript = pve-update-script { };

    meta = with lib; {
      description = "Proxmox VE container manager & runtime";
      homepage = "https://git.proxmox.com/?p=pve-container.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
