#!/bin/bash -e

echo "${HOSTNAME}" > "${ROOTFS_DIR}/etc/hostname"

ln -sf /dev/null "${ROOTFS_DIR}/etc/systemd/network/99-default.link"
