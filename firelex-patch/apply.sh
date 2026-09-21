#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PATCH_DIR="$REPO_ROOT/firelex-patch"
ASSETS_DIR="$REPO_ROOT/mobile/android/fenix/app/src/main/assets/extensions"

echo "[firelex-patch] Copying overlay files into the tree..."
cp -Rv "$PATCH_DIR/overlay/." "$REPO_ROOT/"

echo "[firelex-patch] Unpacking bundled extensions into assets..."
declare -A EXT_MAP=(
  ["ublock_origin.xpi"]="ublock"
  ["symfony_bookmarks.xpi"]="symfony-bookmarks"
)
for xpi in "${!EXT_MAP[@]}"; do
  dest="$ASSETS_DIR/${EXT_MAP[$xpi]}"
  rm -rf "$dest"
  mkdir -p "$dest"
  unzip -o -q "$PATCH_DIR/extensions/$xpi" -d "$dest"
  test -f "$dest/manifest.json" || { echo "ERROR: manifest.json missing in $dest"; exit 1; }
done

echo "[firelex-patch] Applying source patches..."
shopt -s nullglob
for patch in "$PATCH_DIR"/patches/*.patch; do
  echo "  -> applying $(basename "$patch")"
  git -C "$REPO_ROOT" apply --verbose "$patch"
done

echo "[firelex-patch] Done."
