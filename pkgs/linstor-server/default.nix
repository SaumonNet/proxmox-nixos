{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle,
  protobuf_31,
  python3,
  makeWrapper,
  jre,
  bashInteractive,
  bcache-tools,
  coreutils,
  cryptsetup,
  drbd,
  gnugrep,
  kmod,
  lsscsi,
  lvm2,
  mount,
  nvme-cli,
  systemdMinimal,
  thin-provisioning-tools,
  util-linux,
  zfs,
  writeScript,
}:

let
  self = stdenv.mkDerivation (finalAttrs: {
    pname = "linstor-server";
    version = "1.33.1";

    src = fetchFromGitHub {
      owner = "LINBIT";
      repo = "linstor-server";
      rev = "v${finalAttrs.version}";
      hash = "sha256-yQEQjNtOPbND1kq+Jm7EegL5iSsm0Fg8QdTXbA8+MBE=";
      fetchSubmodules = true;
      leaveDotGit = true;
      postFetch = ''
        # Extract git info needed for version before removing .git
        git -C $out rev-parse HEAD > $out/.git-revision
        # Remove .git to make the output deterministic
        rm -rf $out/.git $out/linstor-common/.git
      '';
    };

    patches = [ ./build.patch ];
    postPatch = ''
      find . -type f -name "*.java" -exec sed -i {} -e "s|/bin/bash|${bashInteractive}/bin/bash|g" \;
    '';

    nativeBuildInputs = [
      gradle
      protobuf_31
      python3
      makeWrapper
    ];

    buildInputs = [ protobuf_31 ];

    gradleBuildTask = "installDist";

    preBuild = ''
      # Use the git revision saved during fetch instead of running git commands
      GITHASH=$(cat .git-revision)
      VERSION="${finalAttrs.version}" GITHASH="$GITHASH" make versioninfo
    '';

    mitmCache = gradle.fetchDeps {
      pkg = self;
      data = ./deps.json;
    };

    gradleFlags = [ "-Dfile.encoding=utf-8" ];

    doCheck = false;

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/lib/conf
      cp -r build/install/linstor-server/lib/* $out/lib/
      cp server/logback.xml $out/lib/conf/
      makeWrapper ${jre}/bin/java $out/bin/linstor-controller \
        --add-flags "-Xms32M -classpath $out/lib/conf:$out/lib/* com.linbit.linstor.core.Controller" \
        --prefix PATH : ${
          lib.makeBinPath [
            bcache-tools
            coreutils
            cryptsetup
            drbd
            gnugrep
            kmod
            lsscsi
            lvm2
            mount
            nvme-cli
            systemdMinimal
            thin-provisioning-tools
            util-linux
            zfs
          ]
        }

      makeWrapper ${jre}/bin/java $out/bin/linstor-satellite \
        --add-flags "-Xms32M -classpath $out/lib/conf:$out/lib/* com.linbit.linstor.core.Satellite" \
        --prefix PATH : ${
          lib.makeBinPath [
            bcache-tools
            coreutils
            cryptsetup
            drbd
            gnugrep
            kmod
            lsscsi
            lvm2
            mount
            nvme-cli
            systemdMinimal
            thin-provisioning-tools
            util-linux
            zfs
          ]
        }
    '';

    passthru.updateScript = writeScript "update-linstor-server" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p nix-update

      nix-update linstor-server --flake # update version and hash
      bash $(nix build --no-link --print-out-paths .#packages.x86_64-linux.linstor-server.mitmCache.updateScript)
    '';
  });
in
self
