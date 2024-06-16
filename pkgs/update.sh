#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git common-updater-scripts cargo toml-cli jq

set -eu -o pipefail

export PKG_NAME=$1
REPO_URL=$2
REPO_NAME=$(echo "${REPO_URL##*/}" | sed 's#/$##; s#\.git$##')
MESSAGE_PREFIX=${3:-bump version to}
SOURCE_ROOT=${4:-.}
export BASE_DIR=$(pwd)


cd /tmp || { echo "Failed to change directory to /tmp"; exit 1; }

# Clone and pull the latest version
if [ ! -d $REPO_NAME ]; then
    echo "Cloning the $PKG_NAME repository..."
    git clone $REPO_URL || { echo "Failed to clone repository"; exit 1; }
else
    echo "Repository already cloned."
fi

cd $REPO_NAME

git fetch origin && git reset --hard @{u} && git clean -fd

# Find the latest commit with a message containing "bump version to"
LATEST_BUMP_COMMIT=$(git log --grep="$MESSAGE_PREFIX" -n 1 --pretty=format:"%H")
VERSION=$(git log --grep="$MESSAGE_PREFIX" -n 1 --pretty=format:"%s" | sed -E "s/$MESSAGE_PREFIX (.*)/\1/")
echo "Resetting to $LATEST_BUMP_COMMIT"
git reset --hard $LATEST_BUMP_COMMIT

# Remove debian registry
find . -type f -name "config" -path "*/.cargo/*" -exec rm -f {} \;

# If a directory with the package name exists, cd
pushd $SOURCE_ROOT

# Find exactly one Cargo.toml files in the directory tree
cargo_toml=$(find . -type f -name "Cargo.toml")
count=$(echo "$cargo_toml" | wc -l)
if [ -z "$cargo_toml" ]; then count=0; fi
if [ "$count" -gt 1 ]; then
    echo "Error: Found $count Cargo.toml file(s)."
    exit 1
elif [ "$count" -eq 1 ]; then
  # Get the directory containing the Cargo.toml file
  cargo_dir=$(dirname "$cargo_toml")
  echo "Found one Cargo.toml file in directory: $cargo_dir"
  pushd "$cargo_dir"
  
  # Cargo.toml: patch proxmox deps to use Git
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

  transform_git_deps
  cargo generate-lockfile
  cp Cargo.toml $BASE_DIR/pkgs/$PKG_NAME/
  popd

  popd
  
  # Copy exactly one Cargo.lockfiles in the directory tree
  cargo_lock=$(find . -type f -name "Cargo.lock")
  count=$(echo "$cargo_lock" | wc -l)
  if [ -z "$cargo_lock" ]; then count=0; fi
  if [ "$count" -gt 1 ]; then
      echo "Error: Found $count Cargo.lock file(s)."
      exit 1
  elif [ "$count" -eq 1 ]; then  
    echo "Found one Cargo.lock file: $cargo_lock"
    cp $cargo_lock "$BASE_DIR/pkgs/$PKG_NAME/"
  fi
fi

cd $BASE_DIR

echo "Updating $PKG_NAME with hash: $LATEST_BUMP_COMMIT"
update-source-version $PKG_NAME $VERSION --rev=$LATEST_BUMP_COMMIT
