#!/usr/bin/env bash
set -euo pipefail

install -m 644 files/openwebrx.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"
install -m 644 files/openwebrx-plus.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"

gpg --dearmor < files/openwebrx.gpg.key > "${ROOTFS_DIR}/usr/share/keyrings/openwebrx.gpg"
gpg --dearmor < files/openwebrx-plus.gpg.key > "${ROOTFS_DIR}/etc/apt/trusted.gpg.d/openwebrx-plus.gpg"

on_chroot << EOF
apt-get update
EOF
