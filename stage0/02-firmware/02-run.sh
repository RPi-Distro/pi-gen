#!/bin/bash -e

sed -i 's/^update_initramfs=.*/update_initramfs=no/' "${ROOTFS_DIR}/etc/initramfs-tools/update-initramfs.conf"
