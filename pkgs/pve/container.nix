{ lib
, stdenv
, fetchFromGitHub
, callPackage
, perl
  #, pve-ha-manager ? callPackage ./ha-manager.nix { }
, dtach
, lxc
, openssh
, tzdata
}:

let
  perlDeps = with perl.pkgs; with callPackage ../perl-packages.nix { }; [
    #pve-ha-manager
  ];

  perlEnv = perl.withPackages (_: perlDeps);
in

perl.pkgs.toPerlModule (stdenv.mkDerivation {
  pname = "pve-container";
  version = "5.0.4";

  src = fetchFromGitHub {
    owner = "proxmox";
    repo = "pve-container";
    rev = "471d9dfaf34b3004166dc54c190f3a6581f7dee9";
    hash = "sha256-61OJqW7LidwhQE8hdykNsNV5kdqer9nhvA3N6oNgPWQ=";
  };

  sourceRoot = "source/src";

  postPatch = ''
    sed -i Makefile \
      -e "s/pct.1 pct.conf.5 pct.bash-completion pct.zsh-completion //" \
      -e "s,/usr/share/lxc,/build/lxc," \
      -e "/pve-doc-generator/d" \
      -e "/PVE_GENERATING_DOCS/d" \
      -e "/SERVICEDIR/d" \
      -e "/BASHCOMPLDIR/d" \
      -e "/ZSHCOMPLDIR/d" \
      -e "/MAN1DIR/d" \
      -e "/MAN5DIR/d"
  '';

  buildInputs = [ perlEnv ];
  propagatedBuildInputs = perlDeps;
  dontPatchShebangs = true;

  postConfigure = ''
    cp -r ${lxc}/share/lxc /build
    chmod -R +w /build/lxc
  '';

  makeFlags = [
    "DESTDIR=$(out)"
    "PREFIX=$(out)"
    "SBINDIR=$(out)/.bin"
    "PERLDIR=$(out)/${perl.libPrefix}/${perl.version}"
  ];

  #postInstall = ''
  #  sed -i $out/bin/* \
  #    -e "s/-T//" \
  #    -e "1s|$| -I$out/${perl.libPrefix}/${perl.version}|"
  #'';

  postFixup = ''
    find $out -type f | xargs sed -i \
      -e "s|/usr/bin/dtach|${dtach}/bin/dtach|" \
      -e "s|/usr/bin/ssh|${openssh}/bin/ssh|" \
      -e "s|/usr/bin/vncterm||" \
      -e "s|/usr/bin/termproxy||" \
      -e "s|/usr/bin/lxc|${lxc}/bin/lxc|" \
      -e "s|/usr/share/lxc|$out/share/lxc|" \
      -e "s|/usr/share/zoneinfo|${tzdata}/share/zoneinfo|"
  '';

  meta = with lib; {
    description = "Proxmox VE container manager & runtime - read-only mirror";
    homepage = "https://github.com/proxmox/pve-container";
    license = with licenses; [ ];
    maintainers = with maintainers; [ camillemndn julienmalka ];
    platforms = platforms.linux;
  };
})
