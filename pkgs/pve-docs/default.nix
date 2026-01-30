{
  lib,
  stdenv,
  fetchgit,
  perl540,
  proxmox-widget-toolkit,
  asciidoc,
  dblatex,
  graphviz,
  imagemagick,
  librsvg,
  makeWrapper,
  pve-update-script,
  texlive,
}:

let
  perlDeps = with perl540.pkgs; [
    JSON
    TemplateToolkit
  ];

  perlEnv = perl540.withPackages (_: perlDeps);

  # Texlive packages required for PDF generation
  texliveEnv = texlive.withPackages (ps: with ps; [
    scheme-medium
    appendix
    bibtopic
    bookmark
    changebar
    colortbl
    enumitem
    eepic
    fancybox
    fancyhdr
    fancyvrb
    float
    footmisc
    lastpage
    listings
    multirow
    overpic
    pdfpages
    psnfss
    subfigure
    titlesec
    upquote
    courier
    helvetic
    rsfs
    pxfonts
    symbol
    txfonts
    zapfding
  ]);

  # Override dblatex to use our texlive environment
  dblatexBase = dblatex.override {
    enableAllFeatures = true;
    tex = texliveEnv;
  };

  # Wrap dblatex to add librsvg to PATH (needed for SVG conversion)
  dblatexCustom = stdenv.mkDerivation {
    pname = "dblatex-wrapped";
    version = dblatexBase.version;
    
    nativeBuildInputs = [ makeWrapper ];
    
    buildCommand = ''
      mkdir -p $out/bin $out/share
      
      # Wrap the dblatex binary
      makeWrapper ${dblatexBase}/bin/dblatex $out/bin/dblatex \
        --prefix PATH : "${librsvg}/bin"
      
      # Link share directory (contains XSL files etc.)
      ln -s ${dblatexBase}/share/dblatex $out/share/dblatex
    '';
  };

  # Use asciidoc with enableStandardFeatures which:
  # - Patches a2x.py ENV to include PATH for subprocess calls
  # - Hardcodes absolute paths for dblatex, xsltproc, xmllint, epubcheck, etc.
  # Override both texliveMinimal and dblatexFull to use our custom wrapped dblatex.
  asciidocFull = asciidoc.override {
    enableStandardFeatures = true;
    texliveMinimal = texliveEnv;
    dblatexFull = dblatexCustom;
  };
in

stdenv.mkDerivation rec {
  pname = "pve-docs";
  version = "9.1.2";

  src = fetchgit {
    url = "git://git.proxmox.com/git/${pname}.git";
    rev = "b4b8695af1321d5e2f5bf87e6c728662ea5bf6df";
    hash = "sha256-zYQWB85mzrKzyClSQWngtoLlLjH4NbhDaS7fzunioCY=";
  };

  postPatch = ''
    patchShebangs scan-adoc-refs png-verify.pl
    sed -i '1s|#!/usr/bin/perl|#!${perlEnv}/bin/perl|' asciidoc-pve.in

    sed -i Makefile \
      -e '/GITVERSION/d' \
      -e '/pkg-info/d' \
      -e "s|/usr/share/javascript/proxmox-widget-toolkit-dev|${proxmox-widget-toolkit}/share/javascript/proxmox-widget-toolkit|" \
      -e 's|/usr||'

    sed -i images/Makefile -e 's|/usr/share/pve-docs|/share/pve-docs|'

    # Fix PVE_DOCBOOK_CONF: a2x always forces --backend docbook which overrides -b option.
    # Using -f to load pve-docbook.conf after the forced backend ensures [sect5] is defined.
    sed -i Makefile -e 's|PVE_DOCBOOK_CONF=-b.*pve-docbook|PVE_DOCBOOK_CONF=-f asciidoc/pve-docbook.conf|'

    # Fix asciidoc include paths for NixOS: replace Debian paths with Nix store paths
    # The pve-html.conf references /etc/asciidoc/{stylesheets,javascripts} which don't exist on NixOS
    # We need to point to the actual asciidoc package resources directory
    ASCIIDOC_RESOURCES=$(find ${asciidocFull}/lib -type d -name resources -path '*/asciidoc/*' | head -1)
    sed -i asciidoc/pve-html.conf \
      -e "s|/etc/asciidoc/stylesheets|$ASCIIDOC_RESOURCES/stylesheets|g" \
      -e "s|/etc/asciidoc/javascripts|$ASCIIDOC_RESOURCES/javascripts|g"
  '';

  nativeBuildInputs = [
    asciidocFull
    graphviz
    imagemagick
    librsvg
  ];

  buildInputs = [
    perlEnv
  ];

  propagatedBuildInputs = perlDeps;

  makeFlags = [
    "GITVERSION=${src.rev}"
    "DOCRELEASE=${version}"
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
