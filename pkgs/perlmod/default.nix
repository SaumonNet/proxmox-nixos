{
  lib,
  rustPlatform,
  fetchgit,
  perl536,
  libxcrypt,
}:

rustPlatform.buildRustPackage rec {
  pname = "perlmod";
  version = "0.2.0-3";

  src = fetchgit {
    url = "https://git.proxmox.com/git/perlmod.git";
    rev = "88d7d3b742057c57a78fa68fd461b4d4bb8a0fce";
    hash = "sha256-9y6Z6IaIHPgbraT7NGUUsEB/PMWybgRt876sUGHUGjg=";
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
    "bump perlmod-bin to"
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
