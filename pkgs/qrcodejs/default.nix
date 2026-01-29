{
  lib,
  stdenv,
  fetchgit,
  uglify-js,
  pve-update-script,
}:

stdenv.mkDerivation rec {
  pname = "qrcodejs";
  version = "1.20230525-pve1";

  src = fetchgit {
    url = "git://git.proxmox.com/git/libjs-qrcodejs.git";
    rev = "4a28dec7f15ac06e0505a4c2c4fb899a1f45845e";
    hash = "sha256-XRsAQRCT9guaYBXzluBQqdmL7EARMdVR8nw8BhhBSQk=";
  };

  nativeBuildInputs = [ uglify-js ];

  sourceRoot = "${src.name}/src";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/javascript/qrcodejs
    cp qrcode.min.js $out/share/javascript/qrcodejs/
    runHook postInstall
  '';

  passthru.updateScript = pve-update-script { };

  meta = with lib; {
    description = "QRCode.js - Cross-browser QRCode generator for JavaScript";
    homepage = "https://git.proxmox.com/?p=libjs-qrcodejs.git";
    license = licenses.mit;
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
