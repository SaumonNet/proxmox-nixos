{
  lib,
  stdenv,
  fetchgit,
  perl540,
  proxmox-widget-toolkit,
  asciidoc,
  librsvg,
  pve-update-script,
}:

let
  perlDeps = with perl540.pkgs; [ JSON ];

  perlEnv = perl540.withPackages (_: perlDeps);
in

stdenv.mkDerivation rec {
  pname = "pve-docs";
  version = "9.1.1";

  src = fetchgit {
    url = "git://git.proxmox.com/git/${pname}.git";
    rev = "a93964e4a1fdc81fafee4c7e108ea18afa476c5e";
    hash = "sha256-rq45Sb0hTl73DNDESvqimnjjlVBbE/0g2eKR9A9NvGg=";
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

  passthru.updateScript = pve-update-script { };

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
