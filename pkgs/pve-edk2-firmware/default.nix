{
  lib,
  python3,
  pkgs, 
  stdenv, 
  fetchgit,
  ... 
}:

stdenv.mkDerivation rec {
  pname = "pve-edk2-firmware";
  version = "4.2023.08-4";

  src = fetchgit {
    url = "git://git.proxmox.com/git/${pname}.git";
    rev = "17443032f78eaf9ae276f8df9d10c64beec2e048";
    sha256 = "sha256-19frOpnL8xLWIDw58u1zcICU9Qefp936LteyfnSIMCw=";
    fetchSubmodules = true;
  };

  buildInputs = [ ];

  hardeningDisable = [ "format" ];

  nativeBuildInputs = with pkgs; [
    dpkg fakeroot qemu
    bc dosfstools acpica-tools mtools nasm libuuid
    qemu-utils libisoburn python3
  ];

  prePatch = 
  let
    pythonPath = python3.pkgs.makePythonPath (with python3.pkgs; [ pexpect ]);
  in
  ''
    patchShebangs .
    substituteInPlace ./debian/rules \
      --replace-warn /bin/bash ${pkgs.bash}/bin/bash
    substituteInPlace ./Makefile ./debian/rules \
      --replace-warn /usr/share/dpkg ${pkgs.dpkg}/share/dpkg
    substituteInPlace ./debian/rules \
      --replace-warn 'PYTHONPATH=$(CURDIR)/debian/python' 'PYTHONPATH=$(CURDIR)/debian/python:${pythonPath}'
  '';

  buildPhase = 
  let
    mainVersion = builtins.head (lib.splitString "-" version);
  in
  ''
    # Set up build directory (src)
    make ${pname}_${mainVersion}.orig.tar.gz
    pushd ${pname}-${mainVersion}

    # Apply patches using dpkg 
    dpkg-source -b .

    make -f debian/rules build-ovmf
    make -f debian/rules build-ovmf32
  '';

  installPhase = ''
    mkdir -p $out/legacy
    cp -r ./debian/ovmf32-install/. $out/
    cp -r ./debian/ovmf-install/. $out/
    cp -r ./debian/legacy-2M-builds/. $out/legacy/
    cp ./debian/PkKek-1-snakeoil.key $out/
    cp ./debian/PkKek-1-snakeoil.pem $out/
  '';

  meta = {
    description = "edk2 based UEFI firmware modules for virtual machines";
    homepage = "git://git.proxmox.com/git/${pname}.git";
    maintainers = with lib.maintainers; [ ];
  };
 }