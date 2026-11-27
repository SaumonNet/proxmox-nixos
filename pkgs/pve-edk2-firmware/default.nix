{
  lib,
  python3,
  pkgs,
  pkgsCross,
  stdenv,
  fetchgit,
  fetchpatch,
  fetchurl,
  writeShellScriptBin,
  dpkg,
  fakeroot,
  pve-qemu,
  bc,
  dosfstools,
  acpica-tools,
  mtools,
  nasm,
  libuuid,
  qemu-utils,
  libisoburn,
  pve-update-script,
}:

let
  fetchEdk2Patch =
    { name, rev, hash }:
    fetchpatch {
      inherit name hash;
      url = "https://github.com/tianocore/edk2/commit/${rev}.patch";
      stripLen = 1;
      extraPrefix = "edk2/";
    };

  # nasm 3.x rejects 32-bit operand-size instructions inside 64-bit blocks
  # that older nasm accepted (e.g. `push strict dword %[Vector]` in
  # UefiCpuPkg/.../X64/ExceptionHandlerAsm.nasm). edk2 stable-202505, the
  # release pve-edk2-firmware 4.2025.05-2 is built against on Debian Trixie,
  # still relies on the nasm 2.16 leniency. Pin nasm to 2.16.03 for this
  # derivation only.
  nasm_2_16 = nasm.overrideAttrs (_: rec {
    version = "2.16.03";
    src = fetchurl {
      url = "https://www.nasm.us/pub/nasm/releasebuilds/${version}/nasm-${version}.tar.xz";
      hash = "sha256-FBKhx2C70F2wJrbA0WV6/9ZjHNCmPN229zzG1KphYUg=";
    };
    patches = [ ];
  });
in
stdenv.mkDerivation rec {
  pname = "pve-edk2-firmware";
  version = "4.2025.05-3";

  src = fetchgit {
    url = "git://git.proxmox.com/git/${pname}.git";
    rev = "cb8a660902ffa10d58f41933d26ccd3c46544918";
    sha256 = "sha256-exJNFCIzFM90qhJNAlDKSFSVy7leuCd1fPHFE/O0Rkg=";
  };

  patches = [
    (fetchEdk2Patch {
      name = "basetools-stringfuncs-fix-gcc16-warning.patch";
      rev = "3597306191297b504683b83fe7750e49c6a2e836";
      hash = "sha256-Ozk/qMixZoVq95rDmCmNNDWkhuprIRr34AIKCAret8E=";
    })
    (fetchEdk2Patch {
      name = "basetools-efirom-fix-const-warning.patch";
      rev = "9af06ef3cbb052b142f9660c2c01e7aeb401300c";
      hash = "sha256-UAvB0c1faBfhQRFDdZ3/jOJnCYl5MKXpThuKbDK9J98=";
    })
  ];

  hardeningDisable = [
    "format"
    "fortify"
    "trivialautovarinit"
  ];

  nativeBuildInputs = [
    dpkg
    fakeroot
    pve-qemu
    bc
    dosfstools
    acpica-tools
    mtools
    nasm_2_16
    libuuid
    qemu-utils
    libisoburn
    python3
    python3.pkgs.virt-firmware
    # Mock debhelper
    (writeShellScriptBin "dh" "true")
  ]
  ++ (lib.optional (
    stdenv.hostPlatform.system != "aarch64-linux"
  ) pkgsCross.aarch64-multiplatform.stdenv.cc)
  ++ (lib.optional (stdenv.hostPlatform.system != "x86_64-linux") pkgsCross.gnu64.stdenv.cc)
  ++ (lib.optional (stdenv.hostPlatform.system != "riscv64-linux") pkgsCross.riscv64.stdenv.cc);

  depsBuildBuild = [ stdenv.cc ];

  postPatch = ''
    substituteInPlace ./Makefile ./debian/rules \
      --replace-fail '/usr/share/dpkg' '${pkgs.dpkg}/share/dpkg'
    substituteInPlace ./debian/rules \
      --replace-fail '/bin/bash' '${pkgs.bash}/bin/bash'

    # Patch cross compiler paths
    substituteInPlace ./debian/rules \
        --replace-fail 'aarch64-linux-gnu-' '${pkgsCross.aarch64-multiplatform.stdenv.cc.targetPrefix}' \
        --replace-fail 'riscv64-linux-gnu-' '${pkgsCross.riscv64.stdenv.cc.targetPrefix}'
    sed -i '/^EDK2_TOOLCHAIN *=/a export $(EDK2_TOOLCHAIN)_BIN=${pkgsCross.gnu64.stdenv.cc.targetPrefix}' ./debian/rules

    patchShebangs .
  '';

  buildPhase = ''
    runHook preBuild

    mv ./debian ./edk2
    pushd ./edk2
    make -f ./debian/rules override_dh_auto_build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Copy files as mentioned in *.install files
    for f in ./debian/*.install; do
      while IFS= read -r line; do
        read -ra paths <<< "$line"
        dest="$out/''${paths[-1]}"
        mkdir -p "$dest"
        for src in "''${paths[@]::''${#paths[@]}-1}"; do
          cp $src "$dest"
        done
      done < "$f"
    done

    # Create symlinks as mentioned in *.links files
    for f in ./debian/*.links; do
      while IFS= read -r line; do
        read -ra paths <<< "$line"
        dest="$out/''${paths[-1]}"
        for src in "''${paths[@]::''${#paths[@]}-1}"; do
          ln -s "$out/$src" "$dest"
        done
      done < "$f"
    done

    runHook postInstall
  '';

  passthru.updateScript = pve-update-script { 
    extraArgs = [
      "--deb-name"
      "pve-edk2-firmware"
      "--use-git-log"
    ];
  };

  meta = {
    description = "edk2 based UEFI firmware modules for virtual machines";
    homepage = "https://git.proxmox.com/git/${pname}.git";
    maintainers = with lib.maintainers; [
      camillemndn
      codgician
      julienmalka
    ];
  };
}
