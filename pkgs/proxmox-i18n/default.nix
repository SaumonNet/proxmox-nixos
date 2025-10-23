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
  version = "3.4.5";

  src = fetchgit {
    url = "git://git.proxmox.com/git/${pname}.git";
    rev = "24e0aeb18ee90b73a7c98f6d4479ba7e0899ebc7";
    hash = "sha256-oAl3Fs9JW3JFNb2HJAxpPjLcRxU5WKaEiZVtbcKabpU=";
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
