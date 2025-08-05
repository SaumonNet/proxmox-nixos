{
  lib,
  stdenv,
  fetchgit,
  perl538,
  dtach,
  lxc,
  lxcfs,
  openssh,
  pve-common,
  binutils,
  shadow,
  pve-cluster,
  pve-firewall,
  gnutar,
  util-linux,
  iproute2,
  termproxy,
  vncterm,
  xz,
  pve-storage,
  pve-guest-common,
  e2fsprogs,
  tzdata,
}:

let
  perlDeps = [
    pve-guest-common
    pve-common
    pve-cluster
    pve-storage
    pve-firewall
  ];
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

    # See: https://forum.proxmox.com/threads/lxc-container-creation-failing-dsa-ssh-key-generation-error.155813/
    patches = [
      ./fix-dsa-keys.patch
      ./fix-lxc-inc.patch
    ];

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
        -e "s|mkfs.ext4|${e2fsprogs}/bin/mkfs.ext4|" \
        -e "s|lxc-start --version|${lxc}/bin/lxc-start --version|" \
        -e "s|/sbin/ip|${iproute2}/bin/ip|" \
        -e "s|'umount'|'${util-linux}/bin/umount'|" \
        -e "s|'/bin/umount'|'${util-linux}/bin/umount'|" \
        -e "s|@lxcfspath@|${lxcfs}|" \
        -e "s|@lxcpath@|${lxc}|" \
        -e 's|$LXC_CONFIG_PATH/common.seccomp|${lxc}/share/lxc/config/common.seccomp|' \
        -e "s|$cfgpath/userns.conf|$cfgpath/userns.conf.d/01-pve.conf|" \
        -e "s|lxc-console|${lxc}/bin/lxc-console|" \
        -e "s|lxc-device|${lxc}/bin/lxc-device|" \
        -e "s|lxc-attach|${lxc}/bin/lxc-attach|" \
        -e "s|lxc-stop|${lxc}/bin/lxc-stop|" \
        -e "s|lxc-info|${lxc}/bin/lxc-info|" \
        -e "s|'lxc-usernsexec'|'${lxc}/bin/lxc-usernsexec'|" \
        -e "s|'losetup'|'${util-linux}/bin/losetup'|" \
        -e "s|/usr/bin/vncterm|${vncterm}/bin/vncterm|" \
        -e "s|/usr/bin/termproxy|${termproxy}/bin/termproxy|" \
        -e "s|'objdump'|'${binutils}/bin/objdump'|" \
        -e "s|'newgidmap'|'${shadow}/bin/newgidmap'|" \
        -e "s|'newuidmap'|'${shadow}/bin/newuidmap'|" \
        -e "s|'nsenter'|'${util-linux}/bin/nsenter'|" \
        -e "s|/usr/bin/lxc|${lxc}/bin/lxc|" \
        -e "s|/usr/share/lxc|$out/share/lxc|" \
        -e "s|/usr/share/zoneinfo|${tzdata}/share/zoneinfo|"

      sed -i $out/lib/perl5/site_perl/5.38.2/PVE/LXC/Create.pm \
        -e "s|'tar'|'${gnutar}/bin/tar'|"

      sed -i $out/lib/perl5/site_perl/5.38.2/PVE/LXC/Create.pm \
        -e "s|$mechanism eq '${gnutar}'|$mechanism eq 'tar'|"

      sed -i $out/lib/perl5/site_perl/5.38.2/PVE/LXC.pm \
        -e "s|'mount'|'${util-linux}/bin/mount'|" \

      sed -i $out/lib/perl5/site_perl/5.38.2/PVE/VZDump/LXC.pm \
        -e "s|'mount'|'${util-linux}/bin/mount'|" \

      patchShebangs $out/share/lxc/lxcnetaddbr
      patchShebangs $out/share/lxc/pve-container-stop-wrapper
      patchShebangs $out/share/lxc/hooks/lxc-pve-autodev-hook
      patchShebangs $out/share/lxc/hooks/lxc-pve-prestart-hook
      patchShebangs $out/share/lxc/hooks/lxc-pve-poststop-hook

      sed -i $out/share/lxc/hooks/lxc-pve-prestart-hook \
        -e "s/-T//" \
        -e "1s|$| -I$out/${perl538.libPrefix}/${perl538.version}|"

      sed -i $out/share/lxc/hooks/lxc-pve-autodev-hook \
        -e "s/-T//" \
        -e "1s|$| -I$out/${perl538.libPrefix}/${perl538.version}|"

     sed -i $out/share/lxc/hooks/lxc-pve-poststop-hook \
        -e "s/-T//" \
        -e "1s|$| -I$out/${perl538.libPrefix}/${perl538.version}|"

     sed -i $out/share/lxc/lxcnetaddbr \
        -e "s/-T//" \
        -e "1s|$| -I$out/${perl538.libPrefix}/${perl538.version}|"
    '';

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
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
