{
  lib,
  rustPlatform,
  fetchgit,
  perl5,
  libxcrypt,
}:

rustPlatform.buildRustPackage {
  pname = "perlmod";
  version = "0.14.1-1";

  src = fetchgit {
    url = "git://git.proxmox.com/git/perlmod.git";
    rev = "19f342a054ae3d1d7921926182f5ea25380d97da";
    hash = "sha256-UfTZjp7XOUCWQynpA8dLjnej6Fw3s7o3EvWAGr5XYNg=";
  };

  # Note: upstream removed RSPL_set_use_safe_putenv from perlmod/src/glue.c
  # in 0.14.x, so the previous ./remove_safe_putenv.patch is no longer needed.
  patches = [ ];

  cargoLock.lockFile = ./Cargo.lock;

  # `testlib-tests/build.rs` invokes a nested `cargo build -p testlib` and
  # expects the artifact at `<target-dir>/debug/libtestlib.so`. The default
  # `cargoCheckHook` hardcodes `--target <triple>`, which leaks into the
  # nested cargo via `CARGO_BUILD_TARGET` and pushes the output to
  # `<target-dir>/<triple>/debug/` instead. Override checkPhase to run
  # `cargo test` without `--target`.
  checkPhase = ''
    runHook preCheck
    cargo test -j $NIX_BUILD_CORES --offline
    runHook postCheck
  '';

  postPatch = ''
    rm .cargo/config.toml
    patchShebangs perlmod-bin/genpackage.pl
    ln -s ${./Cargo.lock} Cargo.lock
    # testlib-tests/run_tests.rs hardcodes `/usr/bin/perl`; redirect to the
    # perl we depend on so the tests can run inside the nix sandbox.
    substituteInPlace testlib-tests/run_tests.rs \
      --replace-fail '/usr/bin/perl' '${perl5}/bin/perl'
  '';

  nativeBuildInputs = [
    perl5
    perl5.pkgs.Clone # required by testlib-tests/06-magic.t
  ];
  buildInputs = [ libxcrypt ];

  postInstall = ''
    mkdir $out/lib/perlmod
    cp perlmod-bin/genpackage.pl $out/lib/perlmod
  '';

  meta = with lib; {
    description = "Alternative to Perl XS for Rust";
    homepage = "https://git.proxmox.com/?p=perlmod.git";
    license = with licenses; [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
