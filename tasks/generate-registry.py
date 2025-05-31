import argparse
import asyncio
import json
import re
import tempfile
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional
from urllib.parse import urljoin

import aiohttp
import gzip
from bs4 import BeautifulSoup
from debian.deb822 import Packages


@dataclass
class PackageMapping:
    package_name: str
    debian_package_name: str
    git_repository: str
    path: str
    patches: List[str] | None
    exceptions: Dict[str, str]


@dataclass
class AptPackageInfo:
    name: str
    version: str
    date: datetime


@dataclass
class CommitInfo:
    hash: str
    date: datetime


@dataclass
class CrateInfo:
    name: str
    path: str


@dataclass
class NixPackageDefinition:
    name: str
    url: str
    rev: str
    hash: str
    crates: List[CrateInfo] 
    patches: List[str] | None


class ProxmoxNixTool:
    def __init__(self, package_mappings: List[PackageMapping], temp_dir: Path):
        self.package_mappings = {pm.package_name: pm for pm in package_mappings}
        self.debian_package_mappings = {pm.debian_package_name: pm for pm in package_mappings}
        self.temp_dir = temp_dir
        self.pve_repo_url = "http://download.proxmox.com/debian/pve/dists/bookworm/pve-no-subscription/binary-amd64/"
        self.devel_repo_url = "http://download.proxmox.com/debian/devel/dists/bookworm/main/binary-amd64/"
        self._html_listing_cache: Dict[str, str] = {}

    async def _get_packages_index(self, repo_url: str) -> List[dict]:
        packages_url = urljoin(repo_url, "Packages.gz")
        async with aiohttp.ClientSession() as session:
            async with session.get(packages_url) as response:
                response.raise_for_status()
                compressed_data = await response.read()
        return list(Packages.iter_paragraphs(gzip.decompress(compressed_data).decode('utf-8')))
        
    async def get_package_from_pve_repo(self, package_name: str) -> AptPackageInfo:
        packages = await self._get_packages_index(self.pve_repo_url)
        mapping = self.package_mappings.get(package_name)
        matching_packages = [pkg for pkg in packages if pkg.get('Package') == package_name]
        if not matching_packages:
            raise ValueError(f"Package {package_name} not found in pve-no-subscription repository")
        
        latest_pkg = max(matching_packages, key=lambda p: p.get('Version', ''))
        date = await self._get_package_date_from_listing(self.pve_repo_url, latest_pkg['Package'], latest_pkg['Version'])
        if not date:
            print(f"Warning: Could not determine date for {latest_pkg['Package']} version {latest_pkg['Version']}, using now()")
            date = datetime.now()
        
        return AptPackageInfo(name=latest_pkg['Package'], version=latest_pkg['Version'], date=date)

    async def get_rust_packages_before_date(self, cutoff_date: datetime) -> List[AptPackageInfo]:
        packages = await self._get_packages_index(self.devel_repo_url)
        tracked_packages = list(map(lambda x: x.debian_package_name, self.package_mappings.values()))
        rust_packages = []
        
        for pkg in packages:
            pkg_name = pkg.get("Package", "")
            if not pkg_name in tracked_packages:
                continue
    
            version = pkg.get("Version", "")
            try:
                pkg_date = await self._get_package_date_from_listing(self.devel_repo_url, pkg_name, version)
            except Exception:
                continue
    
            if pkg_date is None or pkg_date > cutoff_date:
                continue
    
            print(pkg_name, version, pkg_date)
            rust_packages.append(AptPackageInfo(name=pkg_name, version=version, date=pkg_date))
    
        package_groups = {}
        for pkg in rust_packages:
            if pkg.name not in package_groups or pkg.date > package_groups[pkg.name].date:
                package_groups[pkg.name] = pkg
    
        return list(package_groups.values())
    
    async def find_commit_for_package(self, package_info: AptPackageInfo, path) -> CommitInfo:
        mapping = next((pm for pm in self.package_mappings.values() 
                       if pm.debian_package_name == package_info.name or pm.package_name == package_info.name), None)
        
        if not mapping:
            raise ValueError(f"No repository mapping found for package {package_info.name}")
        
        repo_dir = self.temp_dir / mapping.package_name
        if not repo_dir.exists():
            await self._clone_repository(mapping.git_repository, repo_dir)
        
        commit_hash = await self._find_commit_by_message(repo_dir, path, package_info.version)
        
        if not commit_hash:
            if package_info.version in mapping.exceptions.keys():
                commit_hash = mapping.exceptions[package_info.version]
            else:
                raise ValueError(f"No commit found for {package_info.name} at version {package_info.version}")
        
        commit_date = await self._get_commit_date(repo_dir, commit_hash)
        return CommitInfo(hash=commit_hash, date=commit_date)

    async def _clone_repository(self, repo_url: str, dest_dir: Path):
        dest_dir.parent.mkdir(parents=True, exist_ok=True)
        process = await asyncio.create_subprocess_exec(
            'git', 'clone', repo_url, str(dest_dir),
            stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE)
        
        stdout, stderr = await process.communicate()
        if process.returncode != 0:
            raise RuntimeError(f"Git clone failed: {stderr.decode()}")

    async def _get_package_date_from_listing(self, repo_url: str, debian_pkg_name: str, version: str) -> Optional[datetime]:
        base_name = f"{debian_pkg_name}_{version}"
        if repo_url in self._html_listing_cache:
            rows = self._html_listing_cache[repo_url]
        else:
            async with aiohttp.ClientSession() as session:
                async with session.get(repo_url) as response:
                    if response.status != 200:
                        return None
                    html = await response.text()
                    soup = BeautifulSoup(html, 'html.parser')
                    rows = soup.find_all('a', href=True)
                    self._html_listing_cache[repo_url] = rows
    
        for row in rows:
            href = row['href']
            if href.startswith(base_name) and href.endswith('.deb'):
                line = row.next_sibling
                text_line = line.get_text(" ", strip=True) if line else row.parent.get_text(" ", strip=True)
                match = re.search(r'\d{2}-[A-Za-z]{3}-\d{4} \d{2}:\d{2}', text_line)
                if match:
                    return datetime.strptime(match.group(0), "%d-%b-%Y %H:%M")
        return None

    async def _find_commit_by_message(self, repo_dir: Path, path, version) -> Optional[str]:
        version_relaxed = version.replace("-1", "")
        process = await asyncio.create_subprocess_exec(
            'git', 'log', '--grep', re.escape(version), '--grep', re.escape(version_relaxed), '--format=%H', '-1', "--", path,
            cwd=repo_dir, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE)
        
        stdout, stderr = await process.communicate()
        if process.returncode != 0:
            return None
        
        commit_hash = stdout.decode().strip()
        return commit_hash if commit_hash else None

    async def _get_commit_date(self, repo_dir: Path, commit_hash: str) -> datetime:
        process = await asyncio.create_subprocess_exec(
            'git', 'show', '-s', '--format=%ci', commit_hash,
            cwd=repo_dir, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE)
        
        stdout, stderr = await process.communicate()
        if process.returncode != 0:
            raise RuntimeError(f"Failed to get commit date: {stderr.decode()}")
        
        date_str = stdout.decode().strip()
        return datetime.fromisoformat(date_str.replace(' ', 'T'))

    async def _calculate_nix_hash(self, repo_url: str, commit_hash: str) -> str:
        process = await asyncio.create_subprocess_exec(
            'nix-prefetch-git', '--url', repo_url, '--rev', commit_hash, '--quiet',
            stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE)
    
        stdout, stderr = await process.communicate()
        if process.returncode != 0:
            raise RuntimeError(f"nix-prefetch-git failed: {stderr.decode()}")
    
        result = json.loads(stdout.decode())
        return result['sha256']

    async def process_package(self, package_name: str) -> List[NixPackageDefinition]:
        print(f"Processing package: {package_name}")
        
        main_package_info = await self.get_package_from_pve_repo(package_name)
        path = self.debian_package_mappings[package_name].path
        print(f"Found {main_package_info.name} version {main_package_info.version} published on {main_package_info.date}")

        main_commit = await self.find_commit_for_package(main_package_info, path)
        print(f"Main package commit: {main_commit.hash}")

        rust_packages = await self.get_rust_packages_before_date(main_package_info.date)
        print(f"Found {len(rust_packages)} rust packages before {main_package_info.date}")

        nix_definitions = []
        
        mapping = self.debian_package_mappings[package_name]
        main_hash = await self._calculate_nix_hash(mapping.git_repository, main_commit.hash)
        
        main_def = NixPackageDefinition(
            name=package_name, url=mapping.git_repository, rev=main_commit.hash,
            hash=main_hash, patches = None, crates=[CrateInfo(name=package_name, path=package_name)])
        print(main_def)
        
        for rust_pkg in rust_packages:
            try:
                pkg_mapping = self._find_mapping_for_rust_package(rust_pkg.name)
                path = self.debian_package_mappings[rust_pkg.name].path
                commit = await self.find_commit_for_package(rust_pkg, path)
                if pkg_mapping:
                    pkg_hash = await self._calculate_nix_hash(pkg_mapping.git_repository, commit.hash)
                    map_pkg = self.debian_package_mappings[rust_pkg.name]
                    crate_name = map_pkg.package_name

                    rust_def = NixPackageDefinition(
                        name=rust_pkg.name, url=pkg_mapping.git_repository, rev=commit.hash,
                        hash=pkg_hash, patches=map_pkg.patches, crates=[CrateInfo(name=crate_name, path=path)])
                    nix_definitions.append(rust_def)
                    print(f"Processed {rust_pkg.name}: {commit.hash}")
            except Exception as e:
                print(f"Warning: Failed to process {rust_pkg.name}: {e}")
        
        return nix_definitions

    def _find_mapping_for_rust_package(self, rust_package_name: str) -> Optional[PackageMapping]:
        if rust_package_name.startswith('librust-') and rust_package_name.endswith('-dev'):
            crate_name = rust_package_name[8:-4]
            return self.package_mappings.get(crate_name)
        return None

    def generate_nix_output(self, definitions: List[NixPackageDefinition]) -> str:
        output = "[\n"
        for defn in definitions:
            patches = ""
            if defn.patches is not None:
                   mapped = list(map(lambda x: "../" + x, defn.patches))
                   patches = f"patches = [ {" ".join(mapped)} ];"
            output += f"""  {{
    name = "{defn.name}";
    url = "{defn.url}";
    rev = "{defn.rev}";
    {patches}
    sha256 = "{defn.hash}";
    crates = [
"""
            for crate in defn.crates:
                output += f"""      {{
        name = "{crate.name}";
        path = "{crate.path}";
      }}
"""
            output += "    ];\n  }\n"
        output += "]\n"
        return output


def load_package_mappings(mapping_file: str) -> List[PackageMapping]:
    with open(mapping_file, 'r') as f:
        data = json.load(f)
    
    return [PackageMapping(
        package_name=item['package_name'],
        debian_package_name=item['debian_package_name'],
        git_repository=item['git_repository'],
        path=item.get("path", item["package_name"]),
        patches=item.get("patches", None),
        exceptions=item.get("exceptions", {})
    ) for item in data]


async def main():
    parser = argparse.ArgumentParser(description='Generate Nix packages for Proxmox Rust crates')
    parser.add_argument('--mappings', required=True, help='JSON file with package mappings')
    parser.add_argument('--package', required=True, help='Main package name to process')
    parser.add_argument('--temp-dir', help='Temporary directory for git clones')
    parser.add_argument('--output', help='Output file (default: stdout)')
    
    args = parser.parse_args()
    mappings = load_package_mappings(args.mappings)
    temp_dir = Path(args.temp_dir) if args.temp_dir else Path(tempfile.mkdtemp())
    if args.temp_dir:
        temp_dir.mkdir(parents=True, exist_ok=True)
    
    tool = ProxmoxNixTool(mappings, temp_dir)
    
    try:
        definitions = await tool.process_package(args.package)
        output = tool.generate_nix_output(definitions)
        
        if args.output:
            with open(args.output, 'w') as f:
                f.write(output)
            print(f"Output written to {args.output}")
        else:
            print(output)
    except Exception as e:
        print(f"Error: {e}")
        return 1
    
    return 0


if __name__ == '__main__':
    exit(asyncio.run(main()))
