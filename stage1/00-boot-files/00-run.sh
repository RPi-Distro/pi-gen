#!/bin/bash -e

install -m 644 files/cmdline.txt "${ROOTFS_DIR}/boot/"
if [ "$ENABLE_ARM64"="1" ]; then
	install -m 644 files/config.txt "${ROOTFS_DIR}/boot/config.txt"
else
	install -m 644 files/config.arm64.txt "${ROOTFS_DIR}/boot/config.txt"
fi
