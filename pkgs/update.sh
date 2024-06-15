#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git common-updater-scripts cargo toml-cli jq

set -eu -o pipefail

export PKG_NAME=$1
REPO_URL=$2
REPO_NAME=$(echo "${REPO_URL##*/}" | sed 's#/$##; s#\.git$##')
MESSAGE_PREFIX=${3:-bump version to}
export BASE_DIR=$(pwd)


pushd /tmp || { echo "Failed to change directory to /tmp"; exit 1; }

# Clone and pull the latest version
if [ ! -d $REPO_NAME ]; then
    echo "Cloning the $PKG_NAME repository..."
    git clone $REPO_URL || { echo "Failed to clone repository"; exit 1; }
else
    echo "Repository already cloned."
fi

pushd $REPO_NAME

git reset --hard HEAD && git pull

# Find the latest commit with a message containing "bump version to"
LATEST_BUMP_COMMIT=$(git log --grep="$MESSAGE_PREFIX" -n 1 --pretty=format:"%H")
VERSION=$(git log --grep="$MESSAGE_PREFIX" -n 1 --pretty=format:"%s" | grep -oP '(?<=bump version to )[^ ]+')

# Cargo update
transform_git_deps () {
  local repo_url="https://git.proxmox.com/git/proxmox.git"
  local dependencies=$(toml get Cargo.toml dependencies | jq -r 'keys[]')
  # Remove blank lines to make toml work
  sed -i Cargo.toml -e '/^[[:space:]]*$/d'
  
  for dep in $dependencies; do
    if [[ $dep == perlmod ]]; then
      toml set Cargo.toml dependencies.$dep.git "https://git.proxmox.com/git/perlmod.git" > Cargo.toml.tmp && mv Cargo.toml.tmp Cargo.toml
    elif [[ $dep == proxmox-resource-scheduling ]]; then
      toml set Cargo.toml dependencies.$dep.git "https://git.proxmox.com/git/proxmox-resource-scheduling.git" > Cargo.toml.tmp && mv Cargo.toml.tmp Cargo.toml
    elif [[ $dep == proxmox-* ]]; then
      toml set Cargo.toml dependencies.$dep.git "$repo_url" > Cargo.toml.tmp && mv Cargo.toml.tmp Cargo.toml
    fi
  done
}
export -f transform_git_deps

cd $PKG_NAME || echo "Directory $PKG_NAME does not exist"
find . -type f -name "config" -path "*/.cargo/*" -exec rm -f {} \;
find . -name "Cargo.toml" -execdir sh -c 'transform_git_deps; cargo generate-lockfile; cp Cargo.{lock,toml} $BASE_DIR/pkgs/$PKG_NAME/' \;

popd

popd

echo "Updating $PKG_NAME with hash: $LATEST_BUMP_COMMIT"
update-source-version $PKG_NAME $VERSION --rev=$LATEST_BUMP_COMMIT
