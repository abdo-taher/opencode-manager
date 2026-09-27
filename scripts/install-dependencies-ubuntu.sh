#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run with sudo: sudo ./scripts/install-dependencies-ubuntu.sh" >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  bash \
  coreutils \
  util-linux \
  passwd \
  procps \
  git \
  python3 \
  acl \
  cron \
  findutils \
  grep \
  sed \
  gawk \
  ca-certificates

echo "Dependencies installed."
