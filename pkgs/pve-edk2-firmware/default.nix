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
}:

stdenv.mkDerivation rec {
  pname = "pve-edk2-firmware";
  version = "4.2025.02-4";

  src = fetchgit {
    url = "git://git.proxmox.com/git/${pname}.git";
    rev = "221a2615288791f6673ae4d58d2669230071f4af";
    sha256 = "sha256-Xi9xv6Jgx1ik6ST+oriAopS5bQw0H4u+OMDJVcmqu2g=";
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
    # Mock debhelper
    (writeShellScriptBin "dh" "true") 
  ] ++ (lib.optional (stdenv.hostPlatform.system != "aarch64-linux") pkgsCross.aarch64-multiplatform.stdenv.cc)
    ++ (lib.optional (stdenv.hostPlatform.system != "x86_64-linux") pkgsCross.gnu64.stdenv.cc)
    ++ (lib.optional (stdenv.hostPlatform.system != "riscv64-linux") pkgsCross.riscv64.stdenv.cc);

  depsBuildBuild = [ stdenv.cc ];

  postPatch = 
    let
      pythonPath = python3.pkgs.makePythonPath (with python3.pkgs; [ pexpect ]);
    in
    ''
      substituteInPlace ./Makefile ./debian/rules \
        --replace-fail '/usr/share/dpkg' '${pkgs.dpkg}/share/dpkg'
      substituteInPlace ./debian/rules \
        --replace-fail '/bin/bash' '${pkgs.bash}/bin/bash' \
        --replace-fail 'PYTHONPATH=$(CURDIR)/debian/python' 'PYTHONPATH=$(CURDIR)/debian/python:${pythonPath}'

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

  passthru.updateScript = [
    ../update.py
    pname
    "--url"
    src.url
  ];

  meta = {
    description = "edk2 based UEFI firmware modules for virtual machines";
    homepage = "git://git.proxmox.com/git/${pname}.git";
    maintainers = with lib.maintainers; [ codgician julienmalka ];
  };
 }
