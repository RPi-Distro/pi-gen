#!/bin/bash -e

install -m 644 files/cmdline.txt "${ROOTFS_DIR}/boot/"
sed -i -e "s/CONSOLE1/${CONSOLE1}/" "${ROOTFS_DIR}/boot/cmdline.txt"
sed -i -e "s/CONSOLE2/${CONSOLE2}/" "${ROOTFS_DIR}/boot/cmdline.txt"
install -m 644 files/config.txt "${ROOTFS_DIR}/boot/"
