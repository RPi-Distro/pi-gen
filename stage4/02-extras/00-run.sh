#!/bin/bash -e

# Alacarte fixes
DIRS=(
  ".local"
  ".local/share"
  ".local/share/applications"
  ".local/share/desktop-directories"
)

if [[ "${ENABLE_CLOUD_INIT}" == "0" ]]; then
  BASE_DIR="${ROOTFS_DIR}/home/${FIRST_USER_NAME}"
  OWNER="1000:1000"
else
  BASE_DIR="${ROOTFS_DIR}/etc/skel"
  OWNER="root:root"
fi

for dir in "${DIRS[@]}"; do
  install -v -o "${OWNER%%:*}" -g "${OWNER##*:}" -d "${BASE_DIR}/${dir}"
done
