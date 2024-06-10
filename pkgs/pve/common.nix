{ lib
, stdenv
, fetchgit
, callPackage
, bash
, coreutils
, diffutils
, iproute2
, perl
, glibc
, openvswitch
, proxmox-backup-client
, systemd
, tzdata
, usbutils
, substituteAll
}:

let
  perlDeps = with perl.pkgs; with callPackage ../perl-packages.nix { }; [
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
    ScalarListUtils
    MIMEBase32
    MIMEBase64
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

perl.pkgs.toPerlModule (stdenv.mkDerivation rec {
  pname = "pve-common";
  version = "8.0.6";

  src = fetchgit {
    url = "https://git.proxmox.com/git/${pname}.git";
    rev = "f080ddbdc845b76919ef0a4e1bcb60ade177a9f5";
    hash = "sha256-SGCEPCJOgiJENgKTbvsW+5yR7BZSMvjZgR9Nge3uMsM=";
  };

  sourceRoot = "source/src";

  patches = [
    (substituteAll {
      src = ./ss_fix_path.patch;
      sspath = "${iproute2}/bin/";
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
    "PERLDIR=$(out)/${perl.libPrefix}/${perl.version}"
  ];

  postInstall =
    let
      includeHeaders = "{sys,bits,}/syscall.h " +
        (if (stdenv.buildPlatform.system == "x86_64-linux")
        then "asm/unistd{,_64}.h"
        else "asm{,-generic}/{unistd,bitsperlong}.h");
    in
    ''
      for h in ${includeHeaders}; do
        ${perl}/bin/h2ph -d $out ${glibc.dev}/include/$h
        mkdir -p $out/include/$(dirname $h)
        mv $out${glibc.dev}/include/''${h%.h}.ph $out/include/$(dirname $h)
      done
      mv $out/_h2ph_pre.ph $out/include
      cp -r $out/include/* $out/${perl.libPrefix}/${perl.version}
      rm -r $out/{nix,include}
    '';

  postFixup = ''
    find $out/lib -type f | xargs sed -i \
      -e "/ENV{'PATH'}/d" \
      -e "s|/usr/share/zoneinfo|${tzdata}/share/zoneinfo|" \
      -Ee "s|(/usr)?/s?bin/||"
  '';

  meta = with lib; {
    description = "Proxmox Project's Common Perl Code";
    homepage = "https://github.com/proxmox/pve-common";
    license = with licenses; [ ];
    maintainers = with maintainers; [ camillemndn julienmalka ];
    platforms = platforms.linux;
  };
})


