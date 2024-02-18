{ lib
, stdenv
, fetchFromGitHub
, callPackage
, makeWrapper
, perl
, proxmox-widget-toolkit
, pve-acme
, pve-docs
, pve-ha-manager
, pve-http-server
, ceph
, gnupg
, graphviz
, gzip
, nodePackages
, openvswitch
, openssh
, pve-qemu
, tzdata
, pve-novnc
, iproute2
}:

let
  perlDeps = with perl.pkgs; with callPackage ../perl-packages.nix { }; [
    FileReadBackwards
    NetDNS
    PodParser
    TemplateToolkit
    pve-acme
    pve-ha-manager
    pve-http-server
  ];

  perlEnv = perl.withPackages (_: perlDeps);
in

perl.pkgs.toPerlModule (stdenv.mkDerivation rec {
  pname = "pve-manager";
  version = "8.0.3";

  src = fetchFromGitHub {
    owner = "proxmox";
    repo = "pve-manager";
    rev = "50bcf799d8435b794fe2a79a74aa6df6a1419292";
    hash = "sha256-nd1bRpfPrtqXLByhTVnqWr1l3lLPGcJZfFqLZ2hBjsk=";
  };

  postPatch = ''
    sed -i {defines.mk,configs/Makefile} -e "s,/usr,,"
    sed -i Makefile \
      -e '/GITVERSION/d' \
      -e '/pkg-info/d' \
      -e '/log/d' \
      -e '/architecture/d' \
      -e 's/aplinfo PVE bin www services configs network-hooks test/PVE bin www configs test/'
    sed -i bin/Makefile -e '/pod2man/,+1d' -e '/install -d \$(MAN1DIR)/,+7d'
    patchShebangs configs/country.pl
    sed -i configs/country.pl -e "s|/usr|${tzdata}|"
    #cp PVE/pvecfg.pm{.in,}
    sed -i www/manager6/Makefile -e "/ESLINT/d" -e "s|/usr/bin/asciidoc-pve|${pve-docs}/bin/asciidoc-pve|"
  '';

  buildInputs = [ perlEnv nodePackages.eslint graphviz makeWrapper ];
  propagatedBuildInputs = perlDeps;

  makeFlags = [
    "DESTDIR=$(out)"
    "PVERELEASE=8.0"
    "VERSION=${version}"
    "REPOID=nixos"
    "PERLLIBDIR=$(out)/${perl.libPrefix}/${perl.version}"
    "WIDGETKIT=${proxmox-widget-toolkit}/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
    "BASH_COMPLETIONS="
    "ZSH_COMPLETIONS="
    "CLI_MANS="
    "SERVICE_MANS="
  ];

  postInstall = ''
    rm -r $out/var $out/bin/pve{upgrade,update,version,7to8}
    sed -i $out/{bin/*,share/pve-manager/helpers/pve-startall-delay} -e "s/-T//"
  '';

  postFixup = ''
    find $out/lib -type f | xargs sed -i \
      -e "/API2::APT/d" \
      -e "/ENV{'PATH'}/d" \
      -e "s|/usr/share/javascript|${pve-http-server}/share/javascript|" \
      -e "s|/usr/share/fonts-font-awesome|${pve-http-server}/share/fonts-font-awesome|" \
      -e "s|/usr/share/pve-manager|$out/share/pve-manager|" \
      -e "s|/usr/share/zoneinfo|${tzdata}/share/zoneinfo|" \
      -Ee "s|(/usr)?/s?bin/||" \
      -e "s|/usr/share/novnc-pve|${pve-novnc}/share/webapps/novnc|" 

    for bin in $out/{bin/*,share/pve-manager/helpers/pve-startall-delay}; do
      wrapProgram $bin \
        --prefix PATH : ${lib.makeBinPath [ ceph gzip openssh gnupg openvswitch pve-qemu iproute2 ]} \
        --prefix PERL5LIB : $out/${perl.libPrefix}/${perl.version}
    done      
  '';

  meta = with lib; {
    description = "Read-Only mirror of the Proxmox VE Manager API and Web UI repository";
    homepage = "https://github.com/proxmox/pve-manager";
    license = with licenses; [ ];
    maintainers = with maintainers; [ camillemndn julienmalka ];
    platforms = platforms.linux;
  };
})
