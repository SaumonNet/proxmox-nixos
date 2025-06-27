{
  lib,
  rustPlatform,
  fetchgit,
  perl538,
  libxcrypt,
}:

rustPlatform.buildRustPackage rec {
  pname = "perlmod";
  version = "0.2.0-3";

  src = fetchgit {
    url = "git://git.proxmox.com/git/perlmod.git";
    rev = "1544fc13d7196152409467db416f1791ed121fc3";
    hash = "sha256-/HsItWYgSMkqaXHsvsRR3seuHkzWJfBnAR2DDwcvpw4=";
  };

  patches = [ ./remove_safe_putenv.patch ];

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    rm .cargo/config.toml
    patchShebangs perlmod-bin/genpackage.pl
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [ perl538 ];
  buildInputs = [ libxcrypt ];

  postInstall = ''
    mkdir $out/lib/perlmod
    cp perlmod-bin/genpackage.pl $out/lib/perlmod
  '';

  passthru.updateScript = [
    ../update.py
    pname
    "--url"
    src.url
    "--prefix"
    "bump perlmod-bin to"
    "--root"
    pname
  ];

  meta = with lib; {
    description = "Alternative to Perl XS for Rust";
    homepage = "git://git.proxmox.com/?p=perlmod.git";
    license = with licenses; [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
