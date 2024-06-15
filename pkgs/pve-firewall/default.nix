{
  lib,
  stdenv,
  fetchgit,
  makeWrapper,
  perl,
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
  perlEnv = perl.withPackages (_: perlDeps);
in

perl.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-firewall";
    version = "5.0.7";

    src = fetchgit {
      url = "https://git.proxmox.com/git/${pname}.git";
      rev = "4339ef1526fd482f800438fbdeec2f6b50133be2";
      hash = "sha256-bAbObcdrxTY6VVwpP3fH8+7TBudlViQHNTVPjZdm8c8=";
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
      "PERLDIR=$(out)/${perl.libPrefix}/${perl.version}"
    ];

    postFixup = ''
      wrapProgram $out/bin/pve-firewall \
        --prefix PATH : ${
          lib.makeBinPath [
            ipset
            iptables
          ]
        } \
        --prefix PERL5LIB : $out/${perl.libPrefix}/${perl.version}
    '';

    meta = with lib; {
      description = "Firewall test scripts";
      homepage = "https://github.com/proxmox/pve-firewall";
      license = with licenses; [ ];
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
