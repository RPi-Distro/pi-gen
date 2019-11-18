#!/bin/bash -e

if [ ! -d "${ROOTFS_DIR}" ] || [ "${USE_QCOW2}" = "1" ]; then
	bootstrap buster "${ROOTFS_DIR}" http://raspbian.raspberrypi.org/raspbian/
fi
