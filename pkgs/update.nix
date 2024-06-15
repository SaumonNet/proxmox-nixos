{ pname, src }:

''
  PKG_NAME=${pname}
  REPO_URL=$(echo ${src.url} | sed 's/^"\(.*\)"$/\1/')
  
  # Change directory to the Zotero Git repository
  pushd /tmp || { echo "Failed to change directory to /tmp; exit 1; }

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
''
