{
  lib,
  stdenv,
  fetchgit,
  perl5,
  gettext,
  pve-update-script,
}:

let
  perlDeps = with perl5.pkgs; [
    Encode
    GetoptLong
    JSON
    LocalePO
  ];

  perlEnv = perl5.withPackages (_: perlDeps);
in
stdenv.mkDerivation rec {
  pname = "proxmox-i18n";
  version = "3.7.4";

  src = fetchgit {
    url = "git://git.proxmox.com/git/${pname}.git";
    rev = "2e644449dd1fd2ad5800295868098b67bfbaf022";
    hash = "sha256-ZcqI+uYEPEv0SlCAV0yrp/XZrCoaEGpHrhmioS8BrfI=";
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
