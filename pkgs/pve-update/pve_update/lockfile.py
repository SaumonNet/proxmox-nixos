import re
import shutil
import subprocess
import tomllib
import tempfile
from pathlib import Path


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
        postPatch = (old.postPatch or "") + ''
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

    with tempfile.TemporaryDirectory(dir=temp_dir) as work_dir:
        work_path = Path(work_dir) / "source"
        shutil.copytree(out_path, work_path)
        work_path.chmod(0o755)
        generated_lockfile = work_path / "Cargo.lock"
        generated_lockfile.unlink(missing_ok=True)
        manifest_path = work_path / "Cargo.toml"
        manifest = manifest_path.read_text()
        if re.search(r"(?m)^wasm-bindgen\s*=", manifest):
            with open(flake_root / "pkgs/proxmox-wasm-builder/Cargo.lock", "rb") as lock:
                wasm_builder_lock = tomllib.load(lock)
            try:
                wasm_bindgen_version = next(
                    package["version"]
                    for package in wasm_builder_lock["package"]
                    if package["name"] == "wasm-bindgen-cli-support"
                )
            except StopIteration as error:
                raise RuntimeError("wasm-bindgen is missing from the WASM builder lockfile") from error
            manifest, replacements = re.subn(
                r'(?m)^(wasm-bindgen\s*=\s*\{\s*version\s*=\s*)"[^"]+"',
                rf'\g<1>"={wasm_bindgen_version}"',
                manifest,
                count=1,
            )
            if replacements != 1:
                raise RuntimeError("failed to pin wasm-bindgen to the CLI version")
            manifest_path.chmod(0o644)
            manifest_path.write_text(manifest)

        command = [
            "cargo",
            "generate-lockfile",
            "--manifest-path",
            str(work_path / "Cargo.toml"),
        ]
        print(f"→ {' '.join(command)}")
        subprocess.run(command, check=True)
        shutil.copyfile(generated_lockfile, lockfile_path)
    print(f"✅ Cargo.lock updated at {lockfile_path}")
