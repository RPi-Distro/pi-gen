#!/bin/bash -e

echo "Copying previous"

if [ ! -d "${ROOTFS_DIR}" ]; then
	copy_previous
fi
