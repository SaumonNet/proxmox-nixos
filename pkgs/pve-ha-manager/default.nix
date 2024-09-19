{
  lib,
  stdenv,
  fetchgit,
  makeWrapper,
  perl536,
  pve-container,
  pve-firewall,
  pve-guest-common,
  pve-qemu-server,
  pve-storage,
  pve-qemu,
  enableLinstor ? false,
}:

let
  perlDeps = [
    pve-container
    pve-firewall
    pve-guest-common
    pve-qemu-server
    (pve-storage.override { inherit enableLinstor; })
  ];
  perlEnv = perl536.withPackages (_: perlDeps);
in

perl536.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-ha-manager";
    version = "4.0.5";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "800a0c3e485f175d914fb7b59dfcd0cd375998de";
      hash = "sha256-zY0tB4Uby3uFlPHNy75weYioSln/Bt4wzf+u7ba4nSE=";
    };

    sourceRoot = "${src.name}/src";

    postPatch = ''
      sed -i Makefile \
        -e "s/ha-manager.1 pve-ha-crm.8 pve-ha-lrm.8 ha-manager.bash-completion pve-ha-lrm.bash-completion //" \
        -e "s/pve-ha-crm.bash-completion ha-manager.zsh-completion pve-ha-lrm.zsh-completion pve-ha-crm.zsh-completion //" \
        -e "/install -m 0644 -D pve-ha-crm.bash-completion/,+5d" \
        -e "/install -m 0644 pve-ha-crm.8/,+6d" \
        -e "s/Werror/Wno-error/" \
        -e "/PVE_GENERATING_DOCS/d" \
        -e "/shell /d"
    '';

    makeFlags = [
      "DESTDIR=$(out)"
      "PREFIX="
      "SBINDIR=/bin"
      "PERLDIR=/${perl536.libPrefix}/${perl536.version}"
    ];

    buildInputs = [
      perlEnv
      makeWrapper
    ];
    propagatedBuildInputs = perlDeps;

    postInstall = ''
      cp ${pve-container}/.bin/pct $out/bin
      cp ${pve-qemu-server}/.bin/* $out/bin
      rm $out/bin/pve-ha-simulator
    '';

    postFixup = ''
      for bin in $out/bin/*; do
        wrapProgram $bin \
          --prefix PATH : ${lib.makeBinPath [ pve-qemu ]} \
          --prefix PERL5LIB : $out/${perl536.libPrefix}/${perl536.version}
      done      
    '';

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
    ];

    meta = with lib; {
      description = "Proxmox VE High Availabillity Manager";
      homepage = "git://git.proxmox.com/?p=pve-ha-manager.git";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
