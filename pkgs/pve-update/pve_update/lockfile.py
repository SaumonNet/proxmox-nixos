import subprocess
from pathlib import Path


def run(cmd: str, **kwargs):
    """Run a shell command and print it."""
    print(f"→ {cmd}")
    subprocess.run(cmd, shell=True, check=True, **kwargs)


def write_cargo_lock(
    package_name: str, derivation_path: Path, temp_dir: Path | str = "/tmp/pve_update"
):
    """
    Regenerate Cargo.lock for a Rust package inside a Nix derivation.

    Args:
        package_name: Name of the nix package (matches flake package).
        derivation_path: Path to nix derivation containing sources.nix & Cargo.lock.
        temp_dir: Temporary working directory (optional).
    """

    flake_root = Path.cwd().resolve()
    lockfile_path = derivation_path / "Cargo.lock"

    # Build a Nix expression to override the package just for lockfile generation
    nix_expr = f"""
    let
      flake = builtins.getFlake "{flake_root}";
      pkg = flake.packages.${{builtins.currentSystem}}."{package_name}" or flake."{package_name}";
    in
      pkg.overrideAttrs (old: {{
        postPatch = old.postPatch + ''
	      cp -r . $out
	      exit
	    '';
      }})
    """

    print(f"→ Building Cargo.lock for {package_name} with Nix...")
    out_path = subprocess.check_output(
        ["nix", "build", "--impure", "--print-out-paths", "--expr", nix_expr],
        text=True,
        cwd=temp_dir,
    ).strip()

    run(
        f"cargo generate-lockfile --manifest-path {out_path}/Cargo.toml --lockfile-path {lockfile_path} -Z unstable-options"
    )
    print(f"✅ Cargo.lock updated at {lockfile_path}")
