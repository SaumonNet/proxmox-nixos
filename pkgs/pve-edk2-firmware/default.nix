{
  lib,
  python3,
  pkgs, 
  pkgsCross,
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

  hardeningDisable = [ "format" "fortify" "trivialautovarinit" ];

  nativeBuildInputs = with pkgs; [
    dpkg fakeroot qemu
    bc dosfstools acpica-tools mtools nasm libuuid
    qemu-utils libisoburn python3
  ] ++ (lib.optional (stdenv.hostPlatform.system != "aarch64-linux") pkgsCross.aarch64-multiplatform.stdenv.cc)
    ++ (lib.optional (stdenv.hostPlatform.system != "x86_64-linux") pkgsCross.gnu64.stdenv.cc)
    ++ (lib.optional (stdenv.hostPlatform.system != "riscv64-linux") pkgsCross.riscv64.stdenv.cc);

  depsBuildBuild = [ stdenv.cc ];

  postPatch = 
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

      # Skip dh calls because we don't need debhelper
      substituteInPlace ./debian/rules \
        --replace-warn 'dh $@' ': dh $@'

      # Patch cross compiler paths
      substituteInPlace ./debian/rules ./**/CMakeLists.txt \
        --replace-warn 'aarch64-linux-gnu-' '${pkgsCross.aarch64-multiplatform.stdenv.cc.targetPrefix}'
      substituteInPlace ./debian/rules ./**/CMakeLists.txt \
        --replace-warn 'riscv64-linux-gnu-' '${pkgsCross.riscv64.stdenv.cc.targetPrefix}'
      sed -i '/^EDK2_TOOLCHAIN *=/a export $(EDK2_TOOLCHAIN)_BIN=${pkgsCross.gnu64.stdenv.cc.targetPrefix}' ./debian/rules

      # Patch paths in produced .install scripts
      substituteInPlace ./debian/*.install \
        --replace-warn '/usr/share/pve-edk2-firmware' "$out/usr/share/pve-edk2-firmware"
    '';

  buildPhase = 
    let
      mainVersion = builtins.head (lib.splitString "-" version);
    in
    ''
      make ${pname}_${mainVersion}.orig.tar.gz
      pushd ${pname}-${mainVersion}
      dpkg-source -b .
      make -f debian/rules override_dh_auto_build
    '';

  installPhase = ''
    # Copy files as mentioned in install scripts
    for ins in ./debian/*.install; do
      while IFS= read -r line; do
        read -ra paths <<< "$line"
        dest="''${paths[-1]}"
        mkdir -p "$dest"
        for src in "''${paths[@]::''${#paths[@]}-1}"; do
          cp $src "$dest"
        done
      done < "$ins"
    done
  '';

  passthru.updateScript = [
    ../update.py
    pname
    "--url"
    src.url
  ];

  meta = {
    description = "edk2 based UEFI firmware modules for virtual machines";
    homepage = "git://git.proxmox.com/git/${pname}.git";
    maintainers = with lib.maintainers; [ ];
  };
 }