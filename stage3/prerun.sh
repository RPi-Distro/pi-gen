#!/bin/bash -e

# Check dev packages installation
DEV_PACKAGES_DIRECTORY="${STAGE_WORK_DIR}/01-install-dev-packages"
if [ "${INSTALL_DEV_PACKAGES:-0}" != "1" ]; then
  echo "Disable dev package installation..."

  mkdir -p "${STAGE_WORK_DIR}/01-install-dev-packages"

  touch "${DEV_PACKAGES_DIRECTORY}/SKIP"
else
  echo "Enable dev packages installation..."
  rm -f "${DEV_PACKAGES_DIRECTORY}/SKIP" 2>/dev/null || true
fi

if [ ! -d "${ROOTFS_DIR}" ]; then
	copy_previous
fi
