{ lib
, stdenv
, fetchFromGitHub
, callPackage
, makeWrapper
, perl
, pve-cluster ? callPackage ./cluster.nix { }
, glib
, ipset
, iptables
, libnetfilter_conntrack
, libnetfilter_log
, libnfnetlink
, pkg-config
}:

let
  perlDeps = [ pve-cluster ];
  perlEnv = perl.withPackages (_: perlDeps);
in

perl.pkgs.toPerlModule (stdenv.mkDerivation {
  pname = "pve-firewall";
  version = "5.0.2";

  src = fetchFromGitHub {
    owner = "proxmox";
    repo = "pve-firewall";
    rev = "0d28aa2abcf2d453504049388b71d27a7ba3259b";
    hash = "sha256-miSdRmnFeqjBR4bHokdk4Pv4XRMivevvLCJeOgvksgA=";
  };

  sourceRoot = "source/src";

  postPatch = ''
    sed -i Makefile \
      -e "s/pve-firewall.8 pve-firewall.bash-completion pve-firewall.zsh-completion//" \
      -e "/install -m 0644 pve-firewall.8/,+4d" \
      -e "s/pve-firewall.8//" \
      -e "/dpkg-buildflags/d"
  '';

  buildInputs = [
    glib
    libnetfilter_conntrack
    libnetfilter_log
    libnfnetlink
    pkg-config
    perlEnv
    makeWrapper
  ];

  makeFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
    "SBINDIR=$(out)/bin"
    "PERLDIR=$(out)/${perl.libPrefix}/${perl.version}"
  ];

  postFixup = ''
    wrapProgram $out/bin/pve-firewall \
      --prefix PATH : ${lib.makeBinPath [ ipset iptables ]} \
      --prefix PERL5LIB : $out/${perl.libPrefix}/${perl.version}
  '';

  meta = with lib; {
    description = "Firewall test scripts";
    homepage = "https://github.com/proxmox/pve-firewall";
    license = with licenses; [ ];
    maintainers = with maintainers; [ camillemndn julienmalka ];
    platforms = platforms.linux;
  };
})
