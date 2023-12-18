#!/bin/bash -e

if [ -f "${ROOTFS_DIR}/etc/initramfs-tools/update-initramfs.conf" ]; then
	sed -i 's/^update_initramfs=.*/update_initramfs=no/' "${ROOTFS_DIR}/etc/initramfs-tools/update-initramfs.conf"
fi
