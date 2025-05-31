{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle,
  protobuf,
  git,
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
}:

let
  self = stdenv.mkDerivation (finalAttrs: {
    pname = "linstor-server";
    version = "1.29.0";

    src = fetchFromGitHub {
      owner = "LINBIT";
      repo = "linstor-server";
      rev = "v${finalAttrs.version}";
      hash = "sha256-+rtvc6FrBQ9YjLiuJpVy/xzSpXp9AgIRNScRd4BPmYw=";
      fetchSubmodules = true;
      leaveDotGit = true;
    };

    patches = [ ./build.patch ];
    postPatch = ''
      find . -type f -name "*.java" -exec sed -i {} -e "s|/bin/bash|${bashInteractive}/bin/bash|g" \;
    '';

    nativeBuildInputs = [
      gradle
      protobuf
      git
      python3
      makeWrapper
    ];

    buildInputs = [ protobuf ];

    gradleBuildTask = "installDist";

    preBuild = ''
      VERSION="${finalAttrs.version}" make versioninfo
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
  });

in
self
