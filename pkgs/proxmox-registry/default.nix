{ fetchgit, stdenv, runCommand, writeText, lib }:
let

  sources = [
    {
      name = "perlmod";
      url = "git://git.proxmox.com/git/perlmod.git";
      rev = "88d7d3b742057c57a78fa68fd461b4d4bb8a0fce";
      hash = "sha256-9y6Z6IaIHPgbraT7NGUUsEB/PMWybgRt876sUGHUGjg=";
      patches = [ ../perlmod/remove_safe_putenv.patch ];
       crates = [
        { name = "perlmod"; path = "perlmod"; }
      ];
    }
    {
      name = "proxmox-git";
      url = "git://git.proxmox.com/git/proxmox.git";
      rev = "5295da1b8af6a72a1e01563a2b50e1c686244e5a";
      hash = "sha256-E8VpINA3HhpcyiDHGjdQy66rtbJ3ifeV4kdtHwXGuys=";
      crates = [
        { name = "proxmox-apt"; path = "proxmox-apt"; }
        { name = "proxmox-http"; path = "proxmox-http"; }
        { name = "proxmox-http-error"; path = "proxmox-http-error"; }
        { name = "proxmox-notify"; path = "proxmox-notify"; }
        { name = "proxmox-openid"; path = "proxmox-openid"; }
        { name = "proxmox-subscription"; path = "proxmox-subscription"; }
        { name = "proxmox-sys"; path = "proxmox-sys"; }
        { name = "proxmox-tfa"; path = "proxmox-tfa"; }
        { name = "proxmox-time"; path = "proxmox-time"; }
      ];
    }
    {
      name = "proxmox-resource-scheduling";
      url = "git://git.proxmox.com/git/proxmox-resource-scheduling.git";
      rev = "09c43554fa4e211504319107997b8c5eaba270ec";
      hash = "sha256-WO5cVkurt7I0V0/7P19dllRaUbd2iFHGClfOnWbxraA=";
       crates = [
        { name = "proxmox-resource-scheduling"; path = "."; }
      ];
    }
  ];

  processed = map (source:
    let
      fetched = fetchgit {
        url = source.url;
        rev = source.rev;
        hash = source.hash;
      };

      patched = if (source ? patches && source.patches != []) then
        stdenv.mkDerivation {
          name = "${source.name}-patched";
          src = fetched;
          patches = source.patches;
          phases = [ "unpackPhase" "patchPhase" "installPhase" ];
          installPhase = ''
            mkdir -p $out
            cp -r . $out/
          '';
        }
      else
        fetched;
    in
      { inherit (source) name crates; path = patched; }
  ) sources;

tomlEntries = lib.concatStringsSep "\n" (lib.flatten (map (s:
    map (crate:
      let
        fullPath = "${s.path}/${crate.path}";
      in
        "${crate.name} = { path = \"${fullPath}\" }"
    ) s.crates
  ) processed));

cargoPatchesToml = writeText "cargo-patches.toml" ''


    [patch.crates-io]
    ${tomlEntries}
  '';

  
in
  runCommand "patched-sources" {} ''
  mkdir -p $out
  ${lib.concatStringsSep "\n" (map (s: ''
    ln -s ${s.path} $out/${s.name}
  '') processed)}
  cp ${cargoPatchesToml} $out/cargo-patches.toml
''
