{
  lib,
  stdenv,
  fetchgit,
  perl538,
  gettext,
  pve-update-script,
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
  version = "3.6.1";

  src = fetchgit {
    url = "git://git.proxmox.com/git/${pname}.git";
    rev = "b43940b4d4387ebb9f101d5659704cb1126da0af";
    hash = "sha256-r9u7KUqz1eh1imWH0mKpOH4Z1T6vgNavl9+QLk33r7M=";
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

  nativeBuildInputs = [
    perlEnv
    gettext
  ];

  passthru.updateScript = pve-update-script {
    extraArgs = [
      "--deb-name"
      "pve-i18n"
      "--use-git-log"
    ];
  };

  meta = with lib; {
    description = "";
    homepage = "https://git.proxmox.com/?p=proxmox-i18n.git";
    license = [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.all;
  };
}
