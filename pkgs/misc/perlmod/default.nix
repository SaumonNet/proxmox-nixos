{ lib
, rustPlatform
, fetchgit
, perl
, libxcrypt
}:

rustPlatform.buildRustPackage rec {
  pname = "perlmod";
  version = "0.13.2-1";

  src = fetchgit {
    url = "https://git.proxmox.com/git/perlmod.git";
    rev = "5dbce0d3d3d89a9fa2d470444d1c1c8b3a780cbe";
    hash = "sha256-ByP1jubfoRfc/DmdGwjT+uxU+jz9LE4KSN/jkRxeBxc=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    rm .cargo/config
    patchShebangs perlmod-bin/genpackage.pl
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [ perl ];
  buildInputs = [ libxcrypt ];

  postInstall = ''
    mkdir $out/lib/perlmod
    cp perlmod-bin/genpackage.pl $out/lib/perlmod
  '';

  meta = with lib; {
    description = "Alternative to perl XS for RUST";
    homepage = "https://git.proxmox.com/?p=perlmod.git";
    license = with licenses; [ ];
    maintainers = with maintainers; [ camillemndn julienmalka ];
    platforms = platforms.linux;
  };
}
