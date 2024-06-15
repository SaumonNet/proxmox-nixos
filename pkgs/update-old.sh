#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash git nix-update jq

# Check if the path argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <proxmox_repos_parent>"
    exit 1
fi

# Assign the first argument as the path to the Zotero Git repository
REPO_PATH=$1

# Assign the second argument as the name mapping file
FIXED_PKG_NAMES=()
for nix_file in pkgs/pve/*.nix; do
  if [[ "$(basename "$nix_file")" != "default.nix" ]]; then
    FIXED_PKG_NAMES+=($(basename "$nix_file" .nix))
  fi
done

# Iterate over the fixed list of package names
for PKG_NAME in "${FIXED_PKG_NAMES[@]}"; do
  REPO_URL=$(nix eval ".#pve-$PKG_NAME.src.url" | sed 's/^"\(.*\)"$/\1/')
  
  # Change directory to the Zotero Git repository
  pushd $REPO_PATH || { echo "Failed to change directory to $REPO_PATH"; exit 1; }

  # Optionally clone and pull the latest version
  if [ ! -d "pve-$PKG_NAME" ]; then
      echo "Cloning the pve-$PKG_NAME repository..."
      git clone $REPO_URL || { echo "Failed to clone repository"; exit 1; }
  else
      echo "Repository already cloned."
  fi
  
  pushd pve-$PKG_NAME
  git pull
  
  # Find the latest commit with a message containing "bump version to"
  LATEST_BUMP_COMMIT=$(git log --grep="bump version to" -n 1 --pretty=format:"%H")
  VERSION=$(git log --grep="bump version to" -n 1 --pretty=format:"%s" | grep -oP '(?<=bump version to )[^ ]+')
  popd
  
  popd
  
  echo "Updating $PKG_NAME with hash: $LATEST_BUMP_COMMIT"
  nix-update --flake --url https://github.com/proxmox/$(echo $REPO_URL | sed -n 's|https://git.proxmox.com/git/\(.*\)\.git.*|\1|p') --version "branch=$LATEST_BUMP_COMMIT" pve-$PKG_NAME
  sed -i "s/version = \".*\";/version = \"$VERSION\";/g" "pkgs/pve/$PKG_NAME.nix"
done
