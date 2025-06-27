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
    version = "8.3.1";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "85d46b41030f538e1e42b570187b0aea3f3f6afd";
      hash = "sha256-kSx0mSP5Htcid2a/bNPNFCsy4jURc/NDHHILWXpQIlk=";
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

      (substituteAll {
        src = ./0004-fix-Don-t-hardcode-bin-bash.patch;
        bashpath = "${bash}/bin/";
      })
    ];

    propagatedBuildInputs = [
      bash
      coreutils
      diffutils
      iproute2
      openvswitch
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
        -e "s|/usr/share/zoneinfo|${tzdata}/share/zoneinfo|" \
        -Ee "s|(/usr)?/s?bin/||" \
        -e "s|'diff'|'${diffutils}/bin/diff'|" \
        -e "s|'ip'|'${iproute2}/bin/ip'|"
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
