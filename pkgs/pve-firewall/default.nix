{
  lib,
  stdenv,
  fetchgit,
  makeWrapper,
  perl538,
  pve-cluster,
  glib,
  ipset,
  iptables,
  libnetfilter_conntrack,
  libnetfilter_log,
  libnfnetlink,
  pkg-config,
}:

let
  perlDeps = [ pve-cluster ];
  perlEnv = perl538.withPackages (_: perlDeps);
in

perl538.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-firewall";
    version = "6.0.0";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "ca4242087e61e5bd048f91dd3b934b60b289312b";
      hash = "sha256-9YBPOiNFmKwTY6wE3g/rJshDV2+2EEo6TrUSF6Bb7QU=";
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
