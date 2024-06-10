{ lib
, stdenv
, fetchgit
, callPackage
, perl
, proxmox-widget-toolkit ? callPackage ../widget-toolkit.nix { }
, asciidoc
, librsvg
}:

let
  perlDeps = with perl.pkgs; with callPackage ../perl-packages.nix { }; [
    JSON
  ];

  perlEnv = perl.withPackages (_: perlDeps);
in

stdenv.mkDerivation rec {
  pname = "pve-docs";
  version = "8.0.4";

  src = fetchgit {
    url = "https://git.proxmox.com/git/${pname}.git";
    rev = "cd44cb4c27486f0d63c332e21ed454014ae1f002";
    hash = "sha256-czVL7h1pTrSWnhkMctW2nlZk3Y3t0EWqUbneGWSZq18=";
  };

  postPatch = ''
    patchShebangs scan-adoc-refs
    sed -i Makefile \
      -e '/GITVERSION/d' \
      -e '/pkg-info/d' \
      -e "s|/usr/share/javascript/proxmox-widget-toolkit-dev|${proxmox-widget-toolkit}/share/javascript/proxmox-widget-toolkit|" \
      -e 's|/usr||' \
      -e "s/gen-install doc-install mediawiki-install/gen-install mediawiki-install/" \
      -e 's|\./asciidoc-pve|$out/bin/asciidoc-pve|'
    #find . -type f | xargs sed -i -e "s|/usr|$out|"
  '';

  buildInputs = [ asciidoc librsvg perlEnv ];
  propagatedBuildInputs = perlDeps;

  makeFlags = [
    "GITVERSION=${src.rev}"
    "INDEX_INCLUDES="
    "DESTDIR=$(out)"
  ];

  meta = with lib; {
    description = "READ ONLY mirror, see https://pve.proxmox.com/wiki/Developer_Documentation";
    homepage = "https://github.com/proxmox/pve-docs";
    license = with licenses; [ ];
    maintainers = with maintainers; [ camillemndn julienmalka ];
    platforms = platforms.linux;
  };
}
