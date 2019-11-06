#!/bin/bash -e

echo "${HOSTNAME}" > "${ROOTFS_DIR}/etc/hostname"
echo "127.0.1.1		${HOSTNAME}" >> "${ROOTFS_DIR}/etc/hosts"

ln -sf /dev/null "${ROOTFS_DIR}/etc/systemd/network/99-default.link"
