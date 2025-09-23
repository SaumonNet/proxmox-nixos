{
  lib,
  stdenv,
  fetchgit,
  bash,
  coreutils,
  diffutils,
  iproute2,
  perl538,
  glibc,
  openvswitch,
  pciutils,
  proxmox-backup-client,
  systemd,
  tzdata,
  usbutils,
  mimebase32,
  mimebase64,
  replaceVars,
}:

let
  perlDeps = with perl538.pkgs; [
    AnyEvent
    Carp
    Clone
    CryptOpenSSLRSA
    CryptOpenSSLRandom
    PathTools
    DataDumper
    TimeDate
    DevelCycle
    #DigestMD5
    DigestSHA
    Encode
    EncodeLocale
    #Exporter
    FilePath
    #FileTemp
    FilesysDf
    GetoptLong
    HTTPMessage
    IOStringy
    IO
    IOSocketIP
    JSON
    #libwwwperl
    LinuxInotify2
    LWPProtocolHttps
    ScalarListUtils
    mimebase32
    mimebase64
    NetDBus
    NetIP
    perlldap
    NetSSLeay
    NetAddrIP
    Socket
    #Storable
    StringShellQuote
    SysSyslog
    TextParsewords
    #TextTabsWrap
    TimeHiRes
    TimeLocal
    URI
    YAMLLibYAML
  ];
in

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-common";
    version = "8.3.4";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "a8f8a80f0c5d5a11e596d50203ca1693faa994d0";
      hash = "sha256-aq7zk0tgLDqyk72tIb2NE2dxP1eSt3WAPS3+Yk7w7Es=";
    };

    sourceRoot = "${src.name}/src";

    patches = [
      (replaceVars ./0001-ss_fix_path.patch {
        sspath = "${iproute2}/bin/";
      })

      ./0002-mknod-mknodat.patch

      (replaceVars ./0003-pci-id-path.patch {
        pciutils = "${pciutils}";
      })
    ];

    propagatedBuildInputs = [
      bash
      coreutils
      diffutils
      iproute2
      proxmox-backup-client
      systemd
      usbutils
    ] ++ perlDeps;

    makeFlags = [
      "PREFIX=$(out)"
      "PERLDIR=$(out)/${perl538.libPrefix}/${perl538.version}"
    ];

    postInstall =
      let
        includeHeaders =
          "{sys,bits,}/syscall.h "
          + (
            if (stdenv.buildPlatform.system == "x86_64-linux") then
              "asm/unistd{,_64}.h"
            else
              "asm{,-generic}/{unistd,bitsperlong}.h"
          );
      in
      ''
        for h in ${includeHeaders}; do
          ${perl538}/bin/h2ph -d $out ${glibc.dev}/include/$h
          mkdir -p $out/include/$(dirname $h)
          mv $out${glibc.dev}/include/''${h%.h}.ph $out/include/$(dirname $h)
        done
        mv $out/_h2ph_pre.ph $out/include
        cp -r $out/include/* $out/${perl538.libPrefix}/${perl538.version}
        rm -r $out/{nix,include}
      '';

    postFixup = ''
      find $out/lib -type f | xargs sed -i \
        -e "/ENV{'PATH'}/d" \
        -e "s|ovs-vsctl|${openvswitch}/bin/ovs-vsctl|" \
        -e "s|/usr/share/zoneinfo|${tzdata}/share/zoneinfo|" \
        -Ee "s|(/usr)?/s?bin/||"
    '';

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
    ];

    meta = with lib; {
      description = "Proxmox Project's Common Perl Code";
      homepage = "git://git.proxmox.com/?p=pve-common.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
