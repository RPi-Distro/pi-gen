#!/bin/bash -e

if [ ! -d "${ROOTFS_DIR}" ]; then
	bootstrap buster "${ROOTFS_DIR}" http://raspbian.raspberrypi.org/raspbian/
fi
