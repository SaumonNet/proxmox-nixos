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
  version = "3.5.0";

  src = fetchgit {
    url = "git://git.proxmox.com/git/${pname}.git";
    rev = "505084f8a10462f6bbd69a8d2f38d4c4cd2b4595";
    hash = "sha256-sBvs3i3mtgOudvDdn7i8zO+9eQc9E+gb+sOqLE6feMQ=";
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
