#!/usr/bin/env bash
set -euo pipefail
cat ../02-install-dev-tools/00-packages | tr '\n' ' ' > "${ROOTFS_DIR}/tmp/dev-tools"

