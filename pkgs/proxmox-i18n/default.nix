{
  lib,
  stdenv,
  fetchgit,
  perl540,
  gettext,
  pve-update-script,
}:

let
  perlDeps = with perl540.pkgs; [
    Encode
    GetoptLong
    JSON
    LocalePO
  ];

  perlEnv = perl540.withPackages (_: perlDeps);
in
stdenv.mkDerivation rec {
  pname = "proxmox-i18n";
  version = "3.6.6";

  src = fetchgit {
    url = "git://git.proxmox.com/git/${pname}.git";
    rev = "b86b5b63ed94b01e0378a42f11467fd1e5851997";
    hash = "sha256-XqYovh3rwcobOhyKpRiZqpARoxl5n4jVD4rNl1ePTtg=";
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
