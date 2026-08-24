{
  lib,
  stdenv,
  fetchgit,
  makeWrapper,
  perl5,
  pve-access-control,
  pve-cluster,
  pve-network,
  pve-rs,
  glib,
  ipset,
  iptables,
  libnetfilter_conntrack,
  libnetfilter_log,
  libnfnetlink,
  pkg-config,
  pve-update-script,
}:

let
  perlDeps = [
    pve-access-control
    pve-cluster
    pve-network
    pve-rs
  ];
  perlEnv = perl5.withPackages (_: perlDeps);
in

perl5.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-firewall";
    version = "6.0.5";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "8a1b22c9c40da0112b40c4723edeba1181fb239e";
      hash = "sha256-kB+Ixnm8jwxxBZvkwd/ttPhW7yIopYfKws2xoZ4byBo=";
    };

    sourceRoot = "${src.name}/src";

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

    propagatedBuildInputs = perlDeps;

    makeFlags = [
      "DESTDIR=$(out)"
      "PREFIX="
      "SBINDIR=$(out)/bin"
      "PERLDIR=$(out)/${perl5.libPrefix}/${perl5.version}"
    ];

    postFixup = ''
      wrapProgram $out/bin/pve-firewall \
        --prefix PATH : ${
          lib.makeBinPath [
            ipset
            iptables
          ]
        } \
        --prefix PERL5LIB : $out/${perl5.libPrefix}/${perl5.version}
    '';

    passthru.updateScript = pve-update-script { };

    meta = with lib; {
      description = "Firewall test scripts";
      homepage = "https://git.proxmox.com/?p=pve-firewall.git";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
