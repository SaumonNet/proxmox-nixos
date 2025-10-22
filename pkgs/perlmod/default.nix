{
  lib,
  rustPlatform,
  fetchgit,
  perl538,
  libxcrypt,
}:

rustPlatform.buildRustPackage rec {
  pname = "perlmod";
  version = "0.2.1-1";

  src = fetchgit {
    url = "git://git.proxmox.com/git/perlmod.git";
    rev = "2c5f34aee080675173ce54b557c8785f24b885ab";
    hash = "sha256-6SoYGQP5ExYiitfO879hDksk9tWLo1W6f98jqQmUznY=";
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
