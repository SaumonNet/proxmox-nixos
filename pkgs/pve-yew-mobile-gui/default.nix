{
  lib,
  stdenv,
  rustPlatform,
  binaryen,
  cargo,
  esbuild,
  grass-sass,
  gzip,
  rustc,
  libuuid,
  lld,
  pkg-config,
  openssl,
  fetchgit,
  proxmox-wasm-builder,
  mkRegistry,
  pve-update-script,
}:

let
  sources = import ./sources.nix;
  registry = mkRegistry sources;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "pve-yew-mobile-gui";
  version = "0.6.2";

  src = fetchgit {
    url = "git://git.proxmox.com/git/ui/pve-yew-mobile-gui.git";
    rev = "0d645b23ae2f733d0be7f6aab0fbe09e41096e1b";
    hash = "sha256-UnhPBJwzsBFidPkNzjC1R+vuU6QYAJok//I07cCEJXY=";

    # FIXME: remove patching submodule address after upgrading to 0.6.3+
    fetchSubmodules = false;
    leaveDotGit = true;

    postFetch = ''
      pushd $out
      git reset
      substituteInPlace ./.gitmodules \
        --replace-fail 'gitolite3@proxdev.maurer-it.com:yew/proxmox-yew-widget-toolkit-assets' \
                       'git://git.proxmox.com/git/ui/proxmox-yew-widget-toolkit-assets.git' \
        --replace-fail 'gitolite3@proxdev.maurer-it.com:/rust/proxmox-api-types' \
                       'git://git.proxmox.com/git/proxmox-api-types.git'

      git submodule update --init --recursive -j ''${NIX_BUILD_CORES:-1} --depth 1
      # Remove .git dirs
      find . -name .git -type f -exec rm -rf {} +
      rm -rf .git/
      popd
    '';
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  postPatch = ''
    # Remove the `[patch.crates-io]` section from original Cargo.toml
    sed -i '/\[patch.crates-io\]/,/^\[/d' Cargo.toml

    rm .cargo/config.toml
    cat ${registry}/cargo-patches.toml >> Cargo.toml
    ln -s ${./Cargo.lock} Cargo.lock

    substituteInPlace ./Makefile \
      --replace-fail 'include /usr/share/dpkg/default.mk' "" \
      --replace-fail 'rust-grass' 'grass'
  '';

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    lld
    rustc
  ];

  buildInputs = [
    binaryen
    esbuild
    grass-sass
    gzip
    libuuid
    pkg-config
    proxmox-wasm-builder
    openssl
    registry
  ];

  makeFlags = [
    "BUILDIR=$NIX_BUILD_TOP"
    "BUILD_MODE=release"
    "DESTDIR=$(out)"
    "GITVERSION:=${finalAttrs.src.rev}"
    "PREFIX="
  ];

  passthru = {
    inherit registry;

    updateScript = pve-update-script { };
  };

  meta = with lib; {
    description = "Mobile web UI for Proxmox VE based on Yew";
    homepage = "https://git.proxmox.com/?p=ui/pve-yew-mobile-gui.git";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
})
