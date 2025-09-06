#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p git common-updater-scripts cargo toml-cli jq

import argparse
import os
import subprocess
import shutil
import re


def run_command(command):
    result = subprocess.run(command, shell=True,
                            text=True, capture_output=True)
    if result.returncode != 0:
        error_message = f"Command '{command}' failed with error: {result.stderr.strip()}"
        raise RuntimeError(error_message)
    return result.stdout.strip()


def main():
    parser = argparse.ArgumentParser(
        description='Update a package to a new version.')
    parser.add_argument('pkg_name', help='Name of the package to update')
    parser.add_argument('--url', help='URL of the Git source', default=None)
    parser.add_argument('--version', help='Specify the version to update to')
    parser.add_argument('--version-prefix', default=None,
                        help='Specify the prefix of targeted update version')
    parser.add_argument('--prefix', default='bump version to',
                        help='Prefix for the commit message')
    parser.add_argument('--root', default='.',
                        help='Root directory of the source')

    args = parser.parse_args()

    base_dir = os.getcwd()
    pkg_name = args.pkg_name
    repo_url = args.url if args.url else f'git://git.proxmox.com/git/{pkg_name}.git'
    old_version = run_command(f'nix eval .#{pkg_name}.version').strip('"')

    repo_name = os.path.basename(repo_url).replace('.git', '')

    temp_dir = '/tmp'
    os.chdir(temp_dir)

    if not os.path.isdir(repo_name):
        print(f'Cloning the {pkg_name} repository...')
        run_command(f'git clone {repo_url}')
    else:
        print('Repository already cloned.')

    os.chdir(repo_name)
    run_command('git fetch origin && git reset --hard @{u} && git clean -fd')

    if args.version:
        version = args.version
    else:
        print('Finding latest version')
        grep_prefix = f'{args.prefix} {args.version_prefix}' if args.version_prefix else args.prefix

        log_output = run_command(
            f'git log --grep="{grep_prefix}" -n 1 --pretty=format:"%s"')
        version_match = re.search(f'{re.escape(args.prefix)} (.*)', log_output)
        version = version_match.group(1) if version_match else None

    if not version:
        print('No version found in the commit messages.')
        return

    rev = run_command(
        f'git log --grep="{args.prefix} {version}" -n 1 --pretty=format:"%H"')
    if len(rev) == 0:
        print("Error: Version was not found in the Git repository.")
        return

    if old_version == version:
        print('New version same as old version, nothing to do.')
    else:
        os.chdir(temp_dir)
        os.chdir(repo_name)
        print(f'Resetting to {rev}')
        run_command(f'git reset --hard {rev}')

        # Remove debian registry
        for root, _, files in os.walk('.'):
            for file in files:
                if file == 'config' and '.cargo' in root:
                    os.remove(os.path.join(root, file))

        os.chdir(args.root)

        cargo_toml_files = [os.path.join(dp, f) for dp, dn, filenames in os.walk(
            '.') for f in filenames if f == 'Cargo.toml']

        if len(cargo_toml_files) > 1:
            print('Error: There should be at most 1 Cargo.toml file.')
            return

        if len(cargo_toml_files) == 1:
            cargo_toml = cargo_toml_files[0]
            cargo_dir = os.path.dirname(cargo_toml)
            print(f'Found a Cargo.toml file in directory: {cargo_dir}')

            os.chdir(cargo_dir)

            def transform_git_deps():
                deps = run_command(
                    'toml get Cargo.toml dependencies | jq -r "keys[]"').splitlines()
                with open('Cargo.toml', 'r') as f:
                    lines = f.readlines()

                with open('Cargo.toml', 'w') as f:
                    for line in lines:
                        if not line.strip():
                            continue
                        f.write(line)

                for dep in deps:
                    if dep.startswith('proxmox-') or dep.startswith('pbs-'):
                        print(f"Patching Cargo dependency '{dep}' to use Git.")
                    if dep == 'perlmod':
                        run_command(
                            f'toml set Cargo.toml dependencies.{dep}.git git://git.proxmox.com/git/perlmod.git > Cargo.toml.tmp && mv Cargo.toml.tmp Cargo.toml')
                    elif dep == 'proxmox-resource-scheduling':
                        run_command(
                            f'toml set Cargo.toml dependencies.{dep}.git git://git.proxmox.com/git/proxmox-resource-scheduling.git > Cargo.toml.tmp && mv Cargo.toml.tmp Cargo.toml')
                    elif dep.startswith('proxmox-'):
                        run_command(
                            f'toml set Cargo.toml dependencies.{dep}.git git://git.proxmox.com/git/proxmox.git > Cargo.toml.tmp && mv Cargo.toml.tmp Cargo.toml')
                    elif dep.startswith('pbs-'):
                        run_command(
                            f'toml set Cargo.toml dependencies.{dep}.git git://git.proxmox.com/git/proxmox-backup.git > Cargo.toml.tmp && mv Cargo.toml.tmp Cargo.toml')
                print("Finished patching Git dependencies.")

            transform_git_deps()
            run_command('cargo generate-lockfile')
            shutil.copy('Cargo.toml', os.path.join(
                base_dir, f'pkgs/{pkg_name}/'))

            cargo_lock_files = [os.path.join(dp, f) for dp, dn, filenames in os.walk(
                temp_dir) for f in filenames if f == 'Cargo.lock']
            if len(cargo_lock_files) != 1:
                print(
                    f'Error: Found {len(cargo_lock_files)} Cargo.lock file(s).')
                return

            cargo_lock = cargo_lock_files[0]
            print(f'Found one Cargo.lock file: {cargo_lock}')
            shutil.copy(cargo_lock, os.path.join(
                base_dir, f'pkgs/{pkg_name}/'))

    os.chdir(base_dir)
    print(f'Updating {pkg_name} with hash: {rev}')
    run_command(f'update-source-version {pkg_name} {version} --rev={rev}')


if __name__ == '__main__':
    main()
