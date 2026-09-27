#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
MANAGER="$ROOT_DIR/bin/opencode-manager"

if [[ ${EUID} -ne 0 ]]; then
  echo "Run with sudo: sudo ./update.sh" >&2
  exit 1
fi

"$ROOT_DIR/scripts/check-dependencies.sh"
"$MANAGER" update
