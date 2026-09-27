#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT_DIR"
VERSION="$(tr -d '[:space:]' < VERSION)"
TAG="v${VERSION}"
PKG="opencode-manager-package-v${VERSION}"
ZIP="$ROOT_DIR/dist/$PKG.zip"
TGZ="$ROOT_DIR/dist/$PKG.tar.gz"

command -v gh >/dev/null || { echo "gh is required" >&2; exit 1; }
gh auth status >/dev/null
[[ -f "$ZIP" ]] || { echo "Missing $ZIP. Run ./scripts/build-release.sh first." >&2; exit 1; }
[[ -f "$TGZ" ]] || { echo "Missing $TGZ. Run ./scripts/build-release.sh first." >&2; exit 1; }

git diff --quiet && git diff --cached --quiet || {
  echo "Working tree has uncommitted changes. Commit the release first." >&2
  exit 1
}

git rev-parse "$TAG" >/dev/null 2>&1 || {
  echo "Tag $TAG does not exist. Create and push it first." >&2
  exit 1
}

if gh release view "$TAG" >/dev/null 2>&1; then
  echo "GitHub release $TAG already exists." >&2
  exit 1
fi

gh release create "$TAG" \
  "$ZIP" \
  "$TGZ" \
  "$ROOT_DIR/dist/SHA256SUMS" \
  --title "OpenCode Manager $TAG" \
  --notes-file README.md

echo "Published GitHub release $TAG"
