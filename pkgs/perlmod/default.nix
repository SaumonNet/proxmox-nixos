{
  lib,
  rustPlatform,
  fetchgit,
  perl536,
  libxcrypt,
}:

rustPlatform.buildRustPackage rec {
  pname = "perlmod";
  version = "0.13.4-1";

  src = fetchgit {
    url = "https://git.proxmox.com/git/perlmod.git";
    rev = "677cb0844646d7bfabcebeaaa35e84440d858195";
    hash = "sha256-w+Uy8G6LSKagwuRt4ja1rgW2/7dWSQ66Qch+dr4NCZ0=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    rm .cargo/config
    patchShebangs perlmod-bin/genpackage.pl
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [ perl536 ];
  buildInputs = [ libxcrypt ];

  postInstall = ''
    mkdir $out/lib/perlmod
    cp perlmod-bin/genpackage.pl $out/lib/perlmod
  '';

  passthru.updateScript = [
    ../update.sh
    pname
    src.url
    "bump perlmod to"
    "perlmod"
  ];

  meta = with lib; {
    description = "Alternative to perl XS for RUST";
    homepage = "https://git.proxmox.com/?p=perlmod.git";
    license = with licenses; [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
