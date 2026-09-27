#!/usr/bin/env bash
set -Eeuo pipefail

required=(bash getent useradd usermod userdel runuser flock script pgrep pkill git python3 realpath grep find install tee tail)
optional=(setfacl crontab)
failed=0

echo "OpenCode Manager dependency check"
for cmd in "${required[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '[PASS] %s\n' "$cmd"
  else
    printf '[FAIL] %s\n' "$cmd"
    failed=1
  fi
done
for cmd in "${optional[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '[PASS] optional: %s\n' "$cmd"
  else
    printf '[INFO] optional missing: %s\n' "$cmd"
  fi
done

if command -v opencode >/dev/null 2>&1; then
  printf '[PASS] opencode in PATH: %s\n' "$(command -v opencode)"
  opencode --version || true
else
  printf '[INFO] opencode not in current PATH; manager can still use SOURCE_BIN if configured.\n'
fi

if (( failed )); then
  echo "Result: MISSING REQUIRED DEPENDENCIES"
  exit 1
fi

echo "Result: READY"
