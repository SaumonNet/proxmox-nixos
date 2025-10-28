#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 git common-updater-scripts dpkg

import argparse
import gzip
import os
import re
import subprocess
import sys
import tempfile
import urllib.request
from debian import debian_support

# Defaults targeting Proxmox public repo / trixie pve-no-subscription
DIST = "trixie"
COMP = "pve-no-subscription"
BASE_URL = "http://download.proxmox.com/debian/pve"
PACKAGES_GZ_URL = f"{BASE_URL}/dists/{DIST}/{COMP}/binary-amd64/Packages.gz"


def run_command(command, check=True):
    """Run a shell command and return stdout (raises on non-zero by default)."""
    result = subprocess.run(command, shell=True, text=True, capture_output=True)
    if check and result.returncode != 0:
        raise RuntimeError(f"Command '{command}' failed: {result.stderr.strip()}")
    return result.stdout.strip()


def parse_packages_gz(url):
    """Stream and parse Packages.gz from the given URL. Yields dicts."""
    with urllib.request.urlopen(url) as resp:
        with gzip.open(resp, "rt", encoding="utf-8") as f:
            entry = {}
            for line in f:
                line = line.rstrip("\n")
                if not line:
                    if entry:
                        yield entry
                        entry = {}
                    continue
                if ":" in line:
                    k, v = line.split(":", 1)
                    entry[k.strip()] = v.strip()
            if entry:
                yield entry


def latest_pkg_info(package):
    """Return (version, filename) of the latest available package using debian_support."""
    candidates = [
        p for p in parse_packages_gz(PACKAGES_GZ_URL) if p.get("Package") == package
    ]
    if not candidates:
        raise RuntimeError(f"Package '{package}' not found in {PACKAGES_GZ_URL}")

    latest = max(candidates, key=lambda p: debian_support.Version(p["Version"]))

    return latest["Version"], latest["Filename"]


def normalize_debian_version(version):
    """
    Strip everything after '~' (pre-release) for git log search.
    Example: '4.2025.02-4~bpo12+1' -> '4.2025.02-4'
    """
    if "~" in version:
        version = version.split("~", 1)[0]
    return version


def extract_source_from_deb(deb_url):
    """Download .deb from deb_url, extract and return the contents of any SOURCE file found."""
    with tempfile.TemporaryDirectory() as td:
        deb_path = os.path.join(td, "pkg.deb")
        urllib.request.urlretrieve(deb_url, deb_path)
        subprocess.run(["dpkg-deb", "-x", deb_path, td], check=True)
        for root, _, files in os.walk(td):
            if "SOURCE" in files:
                with open(os.path.join(root, "SOURCE"), "r", encoding="utf-8") as fh:
                    return fh.read().strip()
    return None


def find_commit_in_source(source_text):
    """Return the first plausible commit hash from SOURCE contents."""
    if not source_text:
        return None
    m = re.search(r"\b[0-9a-f]{7,40}\b", source_text)
    return m.group(0) if m else None


def update_src(
    pkg_name: str,
    deb_name: str | None = None,
    use_git_log: bool = False,
    git_log_prefix: str = "bump version to ",
):
    """
    Update a nix package to the latest Proxmox repo revision.

    Args:
        pkg_name: Name of the nix package (and proxmox git repo)
        deb_name: Optional actual package name in Proxmox repo
        use_git_log: If True, grep the git history instead of extracting SOURCE from .deb
        git_log_prefix: Optional prefix when searching git commit messages
    """
    base_dir = os.getcwd()
    deb_name = deb_name or pkg_name

    # Step 1: fetch latest version info
    print("Fetching package metadata...")
    version, filename = latest_pkg_info(deb_name)
    version = normalize_debian_version(version)
    deb_url = f"{BASE_URL}/{filename}"
    print(f"Latest available: {deb_name} {version}")
    print(f"Deb URL: {deb_url}")

    # Step 2: read old version from nix
    try:
        old_version = (
            run_command(f"nix eval .#{pkg_name}.version", check=True).strip().strip('"')
        )
    except Exception as e:
        print(f"Warning: failed to eval old version: {e}")
        old_version = None

    if old_version and old_version == version:
        print("New version same as old version, nothing to do.")
        return

    # Step 3: resolve commit hash
    if use_git_log:
        with tempfile.TemporaryDirectory() as tmpdir:
            repo_url = run_command(f"nix eval .#{pkg_name}.src.url").strip().strip('"')
            repo_name = os.path.basename(repo_url).replace(".git", "")
            repo_path = os.path.join(tmpdir, repo_name)
            print(f"Cloning {repo_url} in {tmpdir}...")
            run_command(f"git clone {repo_url} {repo_path}")

            os.chdir(repo_path)
            pattern = f"{git_log_prefix}{version}" if git_log_prefix else version
            print(f"Searching git history for version '{pattern}'...")
            try:
                rev = run_command(
                    f"git log --grep='{pattern}' -n 1 --pretty=format:'%H'"
                )
            except RuntimeError:
                print(
                    f"ERROR: Could not find a commit matching version '{pattern}' in git history."
                )
                sys.exit(1)
            if not rev:
                print(
                    f"ERROR: Could not find a commit matching version '{pattern}' in git history."
                )
                sys.exit(1)
    else:
        print("Downloading package and extracting SOURCE...")
        source_text = extract_source_from_deb(deb_url)
        if not source_text:
            print("ERROR: SOURCE file not found inside the .deb")
            sys.exit(1)

        rev = find_commit_in_source(source_text)
        if not rev:
            print("ERROR: could not find a commit hash in SOURCE file")
            sys.exit(1)

    print(f"Resolved commit: {rev}")

    # Step 4: update nix expression
    os.chdir(base_dir)
    print(f"Updating {pkg_name} with hash: {rev} and version: {version}")
    run_command(f"update-source-version {pkg_name} {version} --rev={rev}")
    print("Done.")
