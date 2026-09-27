#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
MANAGER="$ROOT_DIR/bin/opencode-manager"

if [[ ${EUID} -ne 0 ]]; then
  echo "Run with sudo: sudo ./install.sh" >&2
  exit 1
fi

"$ROOT_DIR/scripts/check-dependencies.sh"

if [[ ! -x "$MANAGER" ]]; then
  echo "Manager binary missing: $MANAGER" >&2
  exit 1
fi

install -d -m 755 /etc/opencode-manager
if [[ ! -f /etc/opencode-manager/config.env ]]; then
  install -m 644 "$ROOT_DIR/config/config.env.example" /etc/opencode-manager/config.env
  echo "Created /etc/opencode-manager/config.env"
else
  echo "Keeping existing /etc/opencode-manager/config.env"
fi

"$MANAGER" install
install -m 755 "$MANAGER" /usr/local/bin/opencode-manager

echo
echo "Installed OpenCode Manager $(/usr/local/bin/opencode-manager version)"
echo "Usage:"
echo "  cd /path/to/project"
echo "  sudo opencode-manager doctor"
echo "  sudo opencode-manager run"
