{
  lib,
  stdenv,
  fetchgit,
  makeWrapper,
  perl540,
  pve-container,
  pve-firewall,
  pve-guest-common,
  pve-qemu-server,
  pve-storage,
  pve-qemu,
  enableLinstor ? false,
  pve-update-script,
}:

let
  perlDeps = [
    pve-container
    pve-firewall
    pve-guest-common
    pve-qemu-server
    (pve-storage.override { inherit enableLinstor; })
  ];
  perlEnv = perl540.withPackages (_: perlDeps);
in

perl540.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-ha-manager";
    version = "5.0.5";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "a75d95d378be798b536a593d258c5f203a39ef9c";
      hash = "sha256-KZnsNWmgYBLZ5D2stZ85f7ywI61LUoqiOnnDk4+eUAw=";
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
      "PERLDIR=/${perl540.libPrefix}/${perl540.version}"
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
          --prefix PERL5LIB : $out/${perl540.libPrefix}/${perl540.version}
      done      
    '';

    passthru.updateScript = pve-update-script { };

    meta = with lib; {
      description = "Proxmox VE High Availabillity Manager";
      homepage = "https://git.proxmox.com/?p=pve-ha-manager.git";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
