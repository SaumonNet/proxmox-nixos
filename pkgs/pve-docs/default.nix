{
  lib,
  stdenv,
  fetchgit,
  perl,
  proxmox-widget-toolkit,
  asciidoc,
  librsvg,
}:

let
  perlDeps = with perl.pkgs; [ JSON ];

  perlEnv = perl.withPackages (_: perlDeps);
in

stdenv.mkDerivation rec {
  pname = "pve-docs";
  version = "8.2.2";

  src = fetchgit {
    url = "https://git.proxmox.com/git/${pname}.git";
    rev = "73c340dea7fdfff7d9bdb42fde29c8c02e2b67a4";
    hash = "sha256-E7m+Olvy4NmOdklC+hRu2NsR+byxToDO4SdJ42lkocY=";
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

  buildInputs = [
    asciidoc
    librsvg
    perlEnv
  ];
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
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
