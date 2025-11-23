{
  lib,
  stdenv,
  fetchgit,
  makeWrapper,
  perl540,
  proxmox-widget-toolkit,
  proxmox-acme,
  proxmox-i18n,
  pve-docs,
  pve-ha-manager,
  pve-http-server,
  pve-network,
  pve-yew-mobile-gui,
  cdrkit,
  enableLinstor ? false,
  ceph,
  gnupg,
  graphviz,
  gzip,
  biome,
  openvswitch,
  openssh,
  pve-qemu,
  tzdata,
  pve-novnc,
  pve-xtermjs,
  iproute2,
  termproxy,
  shadow,
  sqlite,
  wget,
  bash,
  zstd,
  util-linux,
  system-sendmail,
  rsync,
  busybox,
  cstream,
  lvm2,
  lxc,
  libfaketime,
  corosync,
  openssl,
  systemd,
  pve-update-script,
}:

let
  perlDeps = with perl540.pkgs; [
    CryptOpenSSLBignum
    FileReadBackwards
    NetDNS
    PodParser
    TemplateToolkit
    proxmox-acme
    (pve-ha-manager.override { inherit enableLinstor; })
    pve-http-server
    pve-network
  ];

  perlEnv = perl540.withPackages (_: perlDeps);
in

perl540.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-manager";
    version = "9.0.11";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "3bf5476b8a4699e2";
      hash = "sha256-Nvi/XxvgYafZTzfzaB+1u6lwtfbCJrua+Gxq6CkAahQ=";
    };

    patches = [
      ./0001-no-apt-update.patch
      ./0002-no-repo-status.patch
    ];

    postPatch = ''
      sed -i {defines.mk,configs/Makefile} -e "s,/usr,,"
      sed -i Makefile \
        -e '/GITVERSION/d' \
        -e "/default.mk/d" \
        -e '/pkg-info/d' \
        -e '/log/d' \
        -e '/architecture/d' \
        -e 's/aplinfo PVE bin www services configs network-hooks test/PVE bin www configs test/'
      sed -i bin/Makefile -e '/pod2man/,+1d' -e '/install -d \$(MAN1DIR)/,+9d'
      #cp PVE/pvecfg.pm{.in,}
      sed -i www/manager6/Makefile -e "/BIOME/d" -e "s|/usr/bin/asciidoc-pve|${pve-docs}/bin/asciidoc-pve|"
    '';

    buildInputs = [
      perlEnv
      biome
      graphviz
      makeWrapper
    ];
    propagatedBuildInputs = perlDeps;

    makeFlags = [
      "DESTDIR=$(out)"
      "PVERELEASE=8.0"
      "VERSION=${version}"
      "REPOID=nixos"
      "PERLLIBDIR=$(out)/${perl540.libPrefix}/${perl540.version}"
      "WIDGETKIT=${proxmox-widget-toolkit}/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
      "BASH_COMPLETIONS="
      "ZSH_COMPLETIONS="
      "CLI_MANS="
      "SERVICE_MANS="
    ];

    postInstall = ''
      rm -r $out/var $out/bin/pve{upgrade,update,version,8to9}
      sed -i $out/{bin/*,share/pve-manager/helpers/pve-startall-delay} -e "s/-T//"
    '';

    postFixup = ''
      find $out/lib -type f | xargs sed -i \
        -e "/API2::APT/d" \
        -e "/ENV{'PATH'}/d" \
        -e "s|/usr/share/javascript|${pve-http-server}/share/javascript|" \
        -e "s|/usr/share/pve-yew-mobile-gui|${pve-yew-mobile-gui}/share/pve-yew-mobile-gui|" \
        -e "s|/usr/share/fonts-font-awesome|${pve-http-server}/share/fonts-font-awesome|" \
        -e "s|/usr/share/fonts-font-logos|${pve-http-server}/share/fonts-font-logos|" \
        -e "s|/usr/share/pve-i18n|${proxmox-i18n}/share/pve-i18n|" \
        -e "s|/usr/share/pve-manager|$out/share/pve-manager|" \
        -e "s|/usr/share/zoneinfo|${tzdata}/share/zoneinfo|" \
        -e "s|/usr/share/pve-xtermjs|${pve-xtermjs}/share/pve-xtermjs|" \
        -Ee "s|(/usr)?/s?bin/||" \
        -e "s|/usr/share/novnc-pve|${pve-novnc}/share/webapps/novnc|" \
        -e "s/Ceph Nautilus required/Ceph Nautilus required - PATH: \$ENV{PATH}\\\n/" \
        -e "s|/usr/share/perl5/\\\$plug|/run/current-system/sw/${perl540.libPrefix}/${perl540.version}/\$plug|"

      # Ceph systemd units in NixOS do not use templates
      find $out/lib -type f -wholename "*Ceph*" | xargs sed -i -e "s/\\\@/-/g"

      sed -i $out/${perl540.libPrefix}/${perl540.version}/PVE/Ceph/Tools.pm \
        -e 's|=> "ceph|=> "${ceph}/bin/ceph|' \
        -e "s|=> 'ceph|=> '${ceph}/bin/ceph|" \
        -e "s|ceph-authtool|${ceph}/bin/ceph-authtool|"

      find $out/bin -type f | xargs sed -i \
        -e "/ENV{'PATH'}/d"

      for bin in $out/{bin/*,share/pve-manager/helpers/pve-startall-delay}; do
        wrapProgram $bin \
          --prefix PATH : ${
            lib.makeBinPath [
              ceph
              cdrkit # cloud-init
              corosync
              gnupg
              gzip
              iproute2
              libfaketime
              openssh
              openssl
              openvswitch
              (pve-ha-manager.override { inherit enableLinstor; })
              pve-qemu
              shadow
              sqlite
              systemd
              termproxy
              util-linux
              wget

              ## dependencies of backup and restore
              bash
              busybox
              cstream
              lvm2
              lxc
              rsync
              system-sendmail
              zstd
            ]
          } \
          --prefix PERL5LIB : $out/${perl540.libPrefix}/${perl540.version}
      done      
    '';

    passthru.updateScript = pve-update-script { };

    meta = with lib; {
      description = "The Proxmox VE Manager API and Web UI repository";
      homepage = "https://git.proxmox.com/?p=pve-manager.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
