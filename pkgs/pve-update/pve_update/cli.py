import argparse
import asyncio
import subprocess
import os
from pathlib import Path
from typing import Optional
from importlib.resources import files

from .update import update_src
from .registry import generate_registry
from .lockfile import write_cargo_lock


def main():
    parser = argparse.ArgumentParser(
        description="Update Proxmox package and Rust dependencies"
    )
    parser.add_argument(
        "package",
        nargs="?",
        default=os.getenv("UPDATE_NIX_ATTR_PATH"),
        help="Package name to update (defaults to $UPDATE_NIX_ATTR_PATH if set)",
    )
    parser.add_argument(
        "--mappings",
        help="Path to JSON mappings file",
        default=files("pve_update").joinpath("mappings.json"),
    )
    parser.add_argument("--temp-dir", help="Temporary directory for git clones")

    # Skip phase flags
    parser.add_argument(
        "--skip-src", action="store_true", help="Skip updating main source + hash"
    )
    parser.add_argument(
        "--skip-registry", action="store_true", help="Skip regenerating sources.nix"
    )
    parser.add_argument(
        "--skip-lock", action="store_true", help="Skip regenerating Cargo.lock"
    )

    parser.add_argument(
        "--deb-name",
        help="Actual package name in the Proxmox repository (if different from nix package)",
    )
    parser.add_argument(
        "--use-git-log",
        action="store_true",
        help="Instead of extracting SOURCE from .deb, grep the git history for the version",
    )
    parser.add_argument(
        "--git-log-prefix",
        help="Optional prefix to use when grepping git commit messages for the version",
        default="bump version to ",
    )

    args = parser.parse_args()
    temp_dir = Path(args.temp_dir) if args.temp_dir else Path("/tmp/pve_update")
    temp_dir.mkdir(parents=True, exist_ok=True)

    # ----------------- PHASE 1: Update main source + hash -----------------
    if not args.skip_src:
        print(f"[INFO] Updating source for {args.package}...")
        update_src(
            pkg_name=args.package,
            deb_name=args.deb_name,
            use_git_log=args.use_git_log,
            git_log_prefix=args.git_log_prefix,
        )
    else:
        print("[INFO] Skipping source update.")

    # ----------------- PHASE 2 & 3: Rust registry + Cargo.lock -----------------
    derivation_attr = f".#{args.package}"
    print(f"[INFO] Evaluating {derivation_attr}.cargoDeps ...")
    try:
        out = subprocess.run(
            ["nix", "eval", f"{derivation_attr}.cargoDeps", "--json"],
            text=True,
            capture_output=True,
            check=True,
        )
        cargo_deps = out.stdout.strip()
        has_cargo_deps = cargo_deps and cargo_deps != "null"
    except subprocess.CalledProcessError:
        has_cargo_deps = False

    if has_cargo_deps:
        if not args.skip_registry:
            print(f"[INFO] {args.package} has cargoDeps, generating sources.nix...")
            sources_content = asyncio.run(
                generate_registry(
                    package_name=args.deb_name,
                    mappings_file=args.mappings,
                    temp_dir=temp_dir,
                )
            )
            sources_path = Path(f"pkgs/{args.package}/sources.nix")
            sources_path.write_text(sources_content)
            print(f"[INFO] sources.nix updated at {sources_path}")
        else:
            print("[INFO] Skipping registry update.")

        if not args.skip_lock:
            print(f"[INFO] Updating Cargo.lock for {args.package}...")
            write_cargo_lock(args.package, Path(f"pkgs/{args.package}"), temp_dir)
            print("[INFO] Cargo.lock updated.")
        else:
            print("[INFO] Skipping Cargo.lock update.")
    else:
        print(f"[INFO] {args.package} does not have cargoDeps, skipping Rust updates.")
