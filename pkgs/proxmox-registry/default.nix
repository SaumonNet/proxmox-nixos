{
  fetchgit,
  stdenv,
  runCommand,
  writeText,
  lib,
  python3,
}:
sources:
let
  workspace-remove = python3.withPackages (python-pkgs: [
    python-pkgs.toml
  ]);

  processed = map (
    source:
    let
      fetched = fetchgit {
        inherit (source) url;
        inherit (source) rev;
        inherit (source) sha256;
      };

      patched =
        if (source ? patches && source.patches != [ ]) then
          stdenv.mkDerivation {
            name = "${source.name}-patched";
            src = fetched;
            inherit (source) patches;
            phases = [
              "unpackPhase"
              "patchPhase"
              "installPhase"
            ];
            installPhase = ''
              mkdir -p $out
                ${lib.concatStringsSep "\n" (
                  map (
                    crate:
                    "${workspace-remove}/bin/python3 ${./remove_workspace_deps.py} --workspace-root . ${crate.path} -o ${crate.path}/Cargo.toml"
                  ) source.crates
                )}
                cp -r . $out/
            '';
          }
        else
          stdenv.mkDerivation {
            name = "${source.name}-filtered";
            src = fetched;
            phases = [
              "unpackPhase"
              "installPhase"
            ];
            installPhase = ''
              mkdir -p $out
                ${lib.concatStringsSep "\n" (
                  map (
                    crate:
                    "${workspace-remove}/bin/python3 ${./remove_workspace_deps.py} --workspace-root . ${crate.path} -o ${crate.path}/Cargo.toml"
                  ) source.crates
                )}
                cp -r . $out/

            '';
          };
    in
    {
      inherit (source) name crates;
      path = patched;
    }
  ) sources;

  tomlEntries = lib.concatStringsSep "\n" (
    lib.flatten (
      map (
        s:
        map (
          crate:
          let
            fullPath = "${s.path}/${crate.path}";
          in
          "${crate.name} = { path = \"${fullPath}\" }"
        ) s.crates
      ) processed
    )
  );

  cargoPatchesToml = writeText "cargo-patches.toml" ''


    [patch.crates-io]
    ${tomlEntries}
  '';

in
runCommand "patched-sources" { } ''
  mkdir -p $out
  ${lib.concatStringsSep "\n" (
    map (s: ''
      ln -s ${s.path} $out/${s.name}
    '') processed
  )}
  cp ${cargoPatchesToml} $out/cargo-patches.toml
''
