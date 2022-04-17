#!/bin/bash -e

rm -f "${ROOTFS_DIR}/etc/apt/apt.conf.d/51cache"
rm -f "${ROOTFS_DIR}/etc/apt/apt.conf.d/52fallback"
rm -f "${ROOTFS_DIR}/bin/detect-proxy"
find "${ROOTFS_DIR}/var/lib/apt/lists/" -type f -delete
on_chroot << EOF
apt-get update
apt-get -y dist-upgrade
apt-get clean
EOF
