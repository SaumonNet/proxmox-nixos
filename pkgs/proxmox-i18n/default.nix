{
  lib,
  stdenv,
  fetchgit,
  perl538,
}:

let
  perlDeps = with perl538.pkgs; [
    Encode
    GetoptLong
    JSON
    LocalePO
  ];

  perlEnv = perl538.withPackages (_: perlDeps);
in
stdenv.mkDerivation rec {
  pname = "proxmox-i18n";
  version = "3.2.4";

  src = fetchgit {
    url = "git://git.proxmox.com/git/${pname}.git";
    rev = "80a4665aa333807539a491cce7feef3f62ffe8aa";
    hash = "sha256-CGH6ceUJVHdljKMDofPWVXHSNA0XOiUVLmZL6Gjkm60=";
  };

  postPatch = ''
    # Remove dpkg pkg-info.mk targets
    substituteInPlace ./Makefile \
      --replace-fail 'include /usr/share/dpkg/pkg-info.mk' ""
    substituteInPlace ./Makefile \
      --replace-fail '/usr/share' '/share'
    patchShebangs .
  '';

  makeFlags = [
    "DESTDIR=$(out)"
  ];

  nativeBuildInputs = [ perlEnv ];

  passthru.updateScript = [
    ../update.py
    pname
    "--url"
    src.url
  ];

  meta = with lib; {
    description = "";
    homepage = "git://git.proxmox.com/?p=proxmox-i18n.git";
    license = [ ];
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
