#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run with sudo: sudo ./uninstall.sh" >&2
  exit 1
fi

PRESERVE_DATA=1
if [[ "${1:-}" == "--purge" ]]; then
  PRESERVE_DATA=0
fi

if [[ -x /usr/local/bin/opencode-manager ]]; then
  /usr/local/bin/opencode-manager stop 2>/dev/null || true
fi

rm -f /usr/local/bin/opencode-manager /usr/local/bin/opencode-user

if [[ $PRESERVE_DATA -eq 1 ]]; then
  echo "Manager binary removed. Preserved /opt/opencode-manager and /etc/opencode-manager."
  echo "Use sudo ./uninstall.sh --purge only if you intentionally want manager state/config removed."
else
  rm -rf /opt/opencode-manager /etc/opencode-manager
  echo "Manager binary, state, logs, and config removed."
  echo "Shared OpenCode target /opt/opencode-shared was NOT deleted automatically."
fi
