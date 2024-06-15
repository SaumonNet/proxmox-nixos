{
  writeScript,
  pname,
  src,
}:

writeScript "update-${pname}" ''
  PKG_NAME=${pname}
  REPO_URL=${src.url}

  pushd /tmp || { echo "Failed to change directory to /tmp"; exit 1; }

  # Clone and pull the latest version
  if [ ! -d "$PKG_NAME" ]; then
      echo "Cloning the $PKG_NAME repository..."
      git clone $REPO_URL || { echo "Failed to clone repository"; exit 1; }
  else
      echo "Repository already cloned."
  fi

  pushd $PKG_NAME
  git pull

  # Find the latest commit with a message containing "bump version to"
  LATEST_BUMP_COMMIT=$(git log --grep="bump version to" -n 1 --pretty=format:"%H")
  VERSION=$(git log --grep="bump version to" -n 1 --pretty=format:"%s" | grep -oP '(?<=bump version to )[^ ]+')
  popd

  popd

  echo "Updating $PKG_NAME with hash: $LATEST_BUMP_COMMIT"
  nix-update --flake --url https://github.com/proxmox/$PKG_NAME.git --version "branch=$LATEST_BUMP_COMMIT" $PKG_NAME
  sed -i "s/version = \".*\";/version = \"$VERSION\";/g" "pkgs/$PKG_NAME/default.nix"
''
