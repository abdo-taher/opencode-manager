#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT_DIR"
VERSION="$(tr -d '[:space:]' < VERSION)"
[[ -n "$VERSION" ]] || { echo "VERSION is empty" >&2; exit 1; }
PKG="opencode-manager-package-v${VERSION}"
DIST="$ROOT_DIR/dist"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

for f in bin/opencode-manager install.sh update.sh uninstall.sh scripts/check-dependencies.sh scripts/install-dependencies-ubuntu.sh scripts/build-release.sh scripts/publish-github-release.sh; do
  bash -n "$f"
done

# Refresh checksums for distributed source files. SHA256SUMS intentionally excludes itself and dist/.
FILES=(
  bin/opencode-manager
  install.sh
  update.sh
  uninstall.sh
  scripts/check-dependencies.sh
  scripts/install-dependencies-ubuntu.sh
  scripts/build-release.sh
  scripts/publish-github-release.sh
  config/config.env.example
  README.md
  VERSION
)
sha256sum "${FILES[@]}" > SHA256SUMS

rm -rf "$DIST"
mkdir -p "$DIST" "$TMP/$PKG"

cp -a bin config scripts install.sh update.sh uninstall.sh README.md SHA256SUMS VERSION "$TMP/$PKG/"

(
  cd "$TMP"
  zip -qr "$DIST/$PKG.zip" "$PKG"
  tar -czf "$DIST/$PKG.tar.gz" "$PKG"
)

sha256sum "$DIST/$PKG.zip" "$DIST/$PKG.tar.gz" > "$DIST/SHA256SUMS"

echo "Built release artifacts:"
ls -lh "$DIST/$PKG.zip" "$DIST/$PKG.tar.gz" "$DIST/SHA256SUMS"
