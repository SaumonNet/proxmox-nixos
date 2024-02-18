{ lib
, stdenv
, fetchFromGitHub
, callPackage
, makeWrapper
, perl
, pve-container ? callPackage ./container.nix { }
, pve-firewall ? callPackage ./firewall.nix { }
, pve-guest-common ? callPackage ./guest-common.nix { }
, pve-qemu-server
, pve-storage
, pve-qemu
}:

let
  perlDeps = [
    pve-container
    pve-firewall
    pve-guest-common
    pve-qemu-server
    pve-storage
  ];
  perlEnv = perl.withPackages (_: perlDeps);
in

perl.pkgs.toPerlModule (stdenv.mkDerivation {
  pname = "pve-ha-manager";
  version = "4.0.2";

  src = fetchFromGitHub {
    owner = "proxmox";
    repo = "pve-ha-manager";
    rev = "dfe080bab1f7f5f12c6de5837c53b47b27355ea6";
    hash = "sha256-bW5++4hXuZtFvV/oP+RNnnjq9ana0VMIEwU1jcbMbTY=";
  };

  sourceRoot = "source/src";

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
    "PERLDIR=/${perl.libPrefix}/${perl.version}"
  ];

  buildInputs = [ perlEnv makeWrapper ];
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
        --prefix PERL5LIB : $out/${perl.libPrefix}/${perl.version}
    done      
  '';

  meta = with lib; {
    description = "Proxmox VE High Availabillity Manager - read-only source mirror";
    homepage = "https://github.com/proxmox/pve-ha-manager";
    license = with licenses; [ ];
    maintainers = with maintainers; [ camillemndn julienmalka ];
    platforms = platforms.linux;
  };
})
