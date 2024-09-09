{
  lib,
  stdenv,
  fetchgit,
  perl536,
  proxmox-widget-toolkit,
  asciidoc,
  librsvg,
}:

let
  perlDeps = with perl536.pkgs; [ JSON ];

  perlEnv = perl536.withPackages (_: perlDeps);
in

stdenv.mkDerivation rec {
  pname = "pve-docs";
  version = "8.2.3";

  src = fetchgit {
    url = "https://git.proxmox.com/git/${pname}.git";
    rev = "f0e702af8d50d433e518365d0cbf9ad871f5790f";
    hash = "sha256-IXsBaQb5291ewV6gNaQ55VLz2ALI1zTrM0BgFGBA0W4=";
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

  passthru.updateScript = [
    ../update.py
    pname
    "--url"
    src.url
  ];

  meta = with lib; {
    description = "Proxmox VE Documentation";
    homepage = "https://git.proxmox.com/?p=pve-docs.git";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
