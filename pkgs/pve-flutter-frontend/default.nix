{
  lib,
  flutter,
  fetchgit,
}:

flutter.buildFlutterApplication rec {
  pname = "pve-flutter-frontend";
  version = "1.8.0";

  src = fetchgit {
    url = "https://git.proxmox.com/git/flutter/pve_flutter_frontend.git";
    rev = "40c8b5f17581565746da5ffc14429469d5f54a56";
    hash = "sha256-hAKyUOklFp9AwWLVEJrIbXPIO7qUVUUiysYDCAX1rOo=";
  };

  src_login = fetchgit {
    url = "https://git.proxmox.com/git/flutter/proxmox_login_manager.git";
    rev = "34d0dd52d119ed5fb16d92dda1235010bd304bd7";
    hash = "sha256-31TjctIBwNDlxAz9eexOKcGDrigChwO6HOBjYpZHycA=";
  };

  postUnpack = ''
    sed -i pubspec.* \
      -E 's|path: \.\./([a-zA-Z0-9_-]+)|git:\n      url: https://git.proxmox.com/git/\1.git|g'
    cat pubspec.yaml
    cp ergoiejge
  '';

  autoPubspecLock = "${src}/pubspec.lock";
  vendorHash = "sha256-cdMO+tr6kYiN5xKXa+uTMAcFf2C75F3wVPrn21G4QPQ=";

  meta = with lib; {
    description = "";
    homepage = "https://git.proxmox.com/git/flutter/pve_flutter_frontend.git";
    license = [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    mainProgram = "pve-flutter-frontend";
    platforms = platforms.all;
  };
}
