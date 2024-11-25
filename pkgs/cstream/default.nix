{ lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
    pname = "cstream";
    version = "4.0.0";
  
    src = fetchurl {
      url = "https://www.cons.org/cracauer/download/cstream-${version}.tar.gz";
      sha256 = "sha256-a8BtfEOG+5jTqRcTQ0wxXZ5tQlyRyIYoG+qiVMDgluM=";
    };
    
    buildInputs = [ stdenv.cc ];

    buildPhase = ''
      make
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp cstream $out/bin
    '';

    meta = {
      description = "A general-purpose stream-handling tool like dd";
      homepage = "https://www.cons.org/cracauer/cstream.html";
      maintainers = with lib.maintainers; [ ];
    };
}