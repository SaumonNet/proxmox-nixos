{
  lib,
  stdenv,
  fetchgit,
  makeWrapper,
  perl538,
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
}:

let
  perlDeps = [ 
    pve-access-control
    pve-cluster 
    pve-network
    pve-rs
  ];
  perlEnv = perl538.withPackages (_: perlDeps);
in

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-firewall";
    version = "5.1.2";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "9b7fdbb369b2767e71272525b37fa6dd74a15330";
      hash = "sha256-lwoemYrZXkKD7+43IwOLu5Dgn1N0Zg/e1siXYBRA6Co=";
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
      "PERLDIR=$(out)/${perl538.libPrefix}/${perl538.version}"
    ];

    postFixup = ''
      wrapProgram $out/bin/pve-firewall \
        --prefix PATH : ${
          lib.makeBinPath [
            ipset
            iptables
          ]
        } \
        --prefix PERL5LIB : $out/${perl538.libPrefix}/${perl538.version}
    '';

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
    ];

    meta = with lib; {
      description = "Firewall test scripts";
      homepage = "git://git.proxmox.com/?p=pve-firewall.git";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
