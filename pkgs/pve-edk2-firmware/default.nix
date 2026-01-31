{
  lib,
  python3,
  pkgs,
  pkgsCross,
  stdenv,
  fetchgit,
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

stdenv.mkDerivation rec {
  pname = "pve-edk2-firmware";
  version = "4.2025.05-2";

  src = fetchgit {
    url = "git://git.proxmox.com/git/${pname}.git";
    rev = "224fdd7df4e9aedea8b6821eb44545cf9c247584";
    sha256 = "sha256-BHjETJ7gB3M1XCIp9OpPDYZZPpl+3+PIS8nDgFBkD6Q=";
  };

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
    nasm
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
